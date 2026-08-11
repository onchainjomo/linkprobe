# linkprobe

![CI](https://github.com/YOUR_USERNAME/linkprobe/actions/workflows/ci.yml/badge.svg)
![npm version](https://img.shields.io/npm/v/linkprobe)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Node.js](https://img.shields.io/badge/node-%3E%3D20-brightgreen)

> A fast, recursive **broken link checker** for websites and Markdown documentation — CLI first, CI ready.

## Features

- 🌐 **Website crawling** — recursively checks all links on a site
- 📝 **Markdown support** — scans `.md` files for broken links
- ⚡ **Concurrent requests** — configurable parallelism for speed
- 🎨 **Color-coded output** — ✅ OK · ❌ broken · ⚠️ redirects
- 📊 **JSON/CSV reports** — machine-readable output for CI
- 🔗 **Anchor checking** — validates `#section` fragments
- 🚫 **Ignore patterns** — skip URLs matching glob patterns

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/linkprobe.git
cd linkprobe
npm install
bash scripts/setup.sh
```

## Quick Start

```bash
# Check a website
node src/linkprobe.js --url https://example.com

# Check markdown files
node src/linkprobe.js --dir ./docs

# Check a single file
node src/linkprobe.js --file README.md
```

## Usage

### Check a Website
```bash
node src/linkprobe.js --url https://mysite.com --depth 3 --concurrency 10
```

### Check Markdown Docs
```bash
node src/linkprobe.js --dir ./docs --ext .md
```

### Export Report
```bash
node src/linkprobe.js --url https://mysite.com --output report.json
node src/linkprobe.js --url https://mysite.com --output report.csv --format csv
```

### CI Mode (exit 1 on broken links)
```bash
node src/linkprobe.js --url https://mysite.com --ci
```

## Options

| Flag | Default | Description |
|------|---------|-------------|
| `--url` | — | Website URL to check |
| `--dir` | — | Directory of Markdown files to check |
| `--file` | — | Single file to check |
| `--depth` | `3` | Max crawl depth |
| `--concurrency` | `5` | Parallel requests |
| `--timeout` | `10000` | Request timeout (ms) |
| `--ignore` | — | URL patterns to ignore (glob) |
| `--output` | — | Save report to file |
| `--format` | `text` | `text`, `json`, `csv` |
| `--ci` | `false` | Exit 1 if broken links found |
| `--no-external` | `false` | Skip external links |

## Example Output

```
linkprobe v1.0.0 — checking https://example.com

✅  200  https://example.com/about
✅  200  https://example.com/docs
❌  404  https://example.com/old-page
⚠️  301  https://example.com/redirect → https://example.com/new

Summary: 4 links checked · 1 broken · 1 redirect · 0 errors
Exit code: 1
```

## npm Scripts

| Command | Description |
|---------|-------------|
| `npm start` | Run linkprobe interactively |
| `npm run check` | Alias for start |
| `npm test` | Run test suite |
| `npm run tracker` | Show achievement progress |
| `npm run roadmap` | Show Day 1 → Month 1 roadmap |

## Achievement Scripts

```bash
bash scripts/unlock-all.sh
bash scripts/quickdraw.sh
bash scripts/yolo.sh
bash scripts/publicist.sh
bash scripts/pull-shark.sh 16
bash scripts/pair-extraordinaire.sh "Name" "email@example.com"
```

## License

MIT — see [LICENSE](LICENSE)
