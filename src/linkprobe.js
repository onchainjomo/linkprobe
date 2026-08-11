#!/usr/bin/env node
/**
 * linkprobe.js
 * Broken link checker for websites and Markdown documentation.
 *
 * Usage:
 *   node src/linkprobe.js --url https://example.com
 *   node src/linkprobe.js --dir ./docs
 *   node src/linkprobe.js --file README.md --output report.json
 */

'use strict';

const http  = require('http');
const https = require('https');
const fs    = require('fs');
const path  = require('path');
const url   = require('url');

// ── Args ────────────────────────────────────────────────────────────────────
const args = process.argv.slice(2);
function getArg(n, d = null) { const i = args.indexOf(n); return i !== -1 && args[i+1] ? args[i+1] : d; }
function hasFlag(n) { return args.includes(n); }

const TARGET_URL  = getArg('--url');
const TARGET_DIR  = getArg('--dir');
const TARGET_FILE = getArg('--file');
const DEPTH       = parseInt(getArg('--depth', '3'), 10);
const CONCURRENCY = parseInt(getArg('--concurrency', '5'), 10);
const TIMEOUT_MS  = parseInt(getArg('--timeout', '10000'), 10);
const OUTPUT      = getArg('--output');
const FORMAT      = getArg('--format', 'text');
const CI_MODE     = hasFlag('--ci');
const NO_EXTERNAL = hasFlag('--no-external');

// ── Colors ──────────────────────────────────────────────────────────────────
const C = { green: '\x1b[32m', red: '\x1b[31m', yellow: '\x1b[33m', gray: '\x1b[90m', reset: '\x1b[0m' };
const ok  = `${C.green}✅ ${C.reset}`;
const bad = `${C.red}❌ ${C.reset}`;
const rdr = `${C.yellow}⚠️  ${C.reset}`;
const err = `${C.red}💥 ${C.reset}`;

// ── Helpers ─────────────────────────────────────────────────────────────────
function extractLinksFromMarkdown(text) {
  const links = [];
  // [text](url) and [text]: url
  const inlineRe = /\[([^\]]*)\]\(([^)]+)\)/g;
  const refRe    = /^\[([^\]]+)\]:\s*(\S+)/gm;
  let m;
  while ((m = inlineRe.exec(text)) !== null) links.push(m[2].split(' ')[0]);
  while ((m = refRe.exec(text)) !== null)    links.push(m[2]);
  return [...new Set(links)];
}

function extractLinksFromHtml(html, base) {
  const links = [];
  const re = /href="([^"#][^"]*)"/gi;
  let m;
  while ((m = re.exec(html)) !== null) {
    try {
      links.push(new url.URL(m[1], base).href);
    } catch {}
  }
  return [...new Set(links)];
}

function fetchUrl(urlStr) {
  return new Promise((resolve) => {
    try {
      const parsed = new url.URL(urlStr);
      const lib = parsed.protocol === 'https:' ? https : http;
      const req = lib.request({ method: 'HEAD', hostname: parsed.hostname,
        path: parsed.pathname + parsed.search,
        port: parsed.port || (parsed.protocol === 'https:' ? 443 : 80),
        headers: { 'User-Agent': 'linkprobe/1.0.0' },
        timeout: TIMEOUT_MS,
      }, (res) => {
        const status = res.statusCode;
        const redir  = res.headers.location || null;
        resolve({ status, redirect: redir });
      });
      req.on('error', (e) => resolve({ status: 0, error: e.message }));
      req.on('timeout', () => { req.destroy(); resolve({ status: 0, error: 'timeout' }); });
      req.end();
    } catch (e) {
      resolve({ status: 0, error: e.message });
    }
  });
}

async function crawl(startUrl, maxDepth) {
  const visited = new Set();
  const results = [];
  const queue   = [{ url: startUrl, depth: 0 }];

  while (queue.length > 0) {
    const batch = queue.splice(0, CONCURRENCY);
    await Promise.all(batch.map(async ({ url: u, depth }) => {
      if (visited.has(u)) return;
      visited.add(u);
      if (NO_EXTERNAL && !u.startsWith(startUrl)) return;

      const result = await fetchUrl(u);
      const entry = { url: u, ...result };
      results.push(entry);

      const sym = result.error ? err : result.status >= 400 ? bad : result.status >= 300 ? rdr : ok;
      const info = result.error ? result.error : result.status;
      process.stdout.write(`${sym} ${String(info).padEnd(5)} ${u}\n`);

      // If HTML, fetch body and extract links for crawling
      if (depth < maxDepth && result.status < 300 && u.startsWith(startUrl)) {
        try {
          const parsed = new url.URL(u);
          const lib = parsed.protocol === 'https:' ? https : http;
          const body = await new Promise((res) => {
            const chunks = [];
            const req = lib.get(u, { headers: { 'User-Agent': 'linkprobe/1.0.0' }, timeout: TIMEOUT_MS }, (r) => {
              r.on('data', c => chunks.push(c));
              r.on('end', () => res(Buffer.concat(chunks).toString('utf8')));
            });
            req.on('error', () => res(''));
          });
          const links = extractLinksFromHtml(body, u);
          links.forEach(link => { if (!visited.has(link)) queue.push({ url: link, depth: depth + 1 }); });
        } catch {}
      }
    }));
  }
  return results;
}

async function checkMarkdownDir(dir) {
  const results = [];
  function walk(d) {
    fs.readdirSync(d, { withFileTypes: true }).forEach(e => {
      const fp = path.join(d, e.name);
      if (e.isDirectory()) walk(fp);
      else if (e.name.endsWith('.md') || e.name.endsWith('.markdown')) {
        const text = fs.readFileSync(fp, 'utf8');
        const links = extractLinksFromMarkdown(text);
        links.forEach(l => results.push({ file: fp, link: l }));
      }
    });
  }
  walk(dir);
  return results;
}

async function checkLinks(pairs) {
  const results = [];
  for (let i = 0; i < pairs.length; i += CONCURRENCY) {
    const batch = pairs.slice(i, i + CONCURRENCY);
    const checked = await Promise.all(batch.map(async ({ file, link }) => {
      if (!link.startsWith('http')) return { file, link, status: 'skipped', error: 'relative' };
      const result = await fetchUrl(link);
      const sym = result.error ? err : result.status >= 400 ? bad : result.status >= 300 ? rdr : ok;
      const info = result.error ? result.error : result.status;
      process.stdout.write(`${sym} ${String(info).padEnd(5)} ${link}  (${path.basename(file)})\n`);
      return { file, link, ...result };
    }));
    results.push(...checked);
  }
  return results;
}

function printSummary(results) {
  const broken   = results.filter(r => (r.status >= 400) || (r.status === 0 && r.error && r.error !== 'relative'));
  const redirects = results.filter(r => r.status >= 300 && r.status < 400);
  const ok_count = results.filter(r => r.status >= 200 && r.status < 300).length;
  console.log(`\n${'─'.repeat(60)}`);
  console.log(`Summary: ${results.length} links checked · ${C.red}${broken.length} broken${C.reset} · ${C.yellow}${redirects.length} redirects${C.reset} · ${C.green}${ok_count} ok${C.reset}`);
  if (broken.length > 0) {
    console.log(`\nBroken links:`);
    broken.forEach(r => console.log(`  ${bad}${r.url || r.link} (${r.error || r.status})`));
  }
  return broken.length;
}

async function main() {
  console.log(`\nlinkprobe v1.0.0`);
  console.log('─'.repeat(60));

  let results = [];

  if (TARGET_URL) {
    console.log(`Crawling: ${TARGET_URL} (depth=${DEPTH})\n`);
    results = await crawl(TARGET_URL, DEPTH);
  } else if (TARGET_DIR) {
    console.log(`Scanning markdown in: ${TARGET_DIR}\n`);
    const pairs = await checkMarkdownDir(TARGET_DIR);
    results = await checkLinks(pairs);
  } else if (TARGET_FILE) {
    console.log(`Checking file: ${TARGET_FILE}\n`);
    const text = fs.readFileSync(TARGET_FILE, 'utf8');
    const links = extractLinksFromMarkdown(text);
    const pairs = links.map(l => ({ file: TARGET_FILE, link: l }));
    results = await checkLinks(pairs);
  } else {
    console.log('Usage:');
    console.log('  node src/linkprobe.js --url https://example.com');
    console.log('  node src/linkprobe.js --dir ./docs');
    console.log('  node src/linkprobe.js --file README.md');
    process.exit(0);
  }

  const brokenCount = printSummary(results);

  if (OUTPUT) {
    fs.writeFileSync(OUTPUT, JSON.stringify(results, null, 2));
    console.log(`\nReport saved: ${OUTPUT}`);
  }

  if (CI_MODE && brokenCount > 0) process.exit(1);
}

main().catch(e => { console.error(e); process.exit(1); });
