#!/usr/bin/env node
/**
 * achievement-tracker.js
 * Shows badge progress and Day 1 → Month 1 roadmap for linkprobe
 */

'use strict';

const { execSync } = require('child_process');

const PROJECT = 'linkprobe';
const showRoadmap = process.argv.includes('--roadmap');

const BADGES = [
  { id: 'quickdraw',   name: 'Quick Draw',           icon: '⚡', desc: 'Closed an issue within 5 min of opening it', script: 'scripts/quickdraw.sh' },
  { id: 'yolo',        name: 'YOLO',                  icon: '🎯', desc: 'Merged a PR without code review',            script: 'scripts/yolo.sh' },
  { id: 'publicist',   name: 'Publicist',             icon: '📢', desc: 'Created a release (v1.0.0)',                 script: 'scripts/publicist.sh' },
  { id: 'pullshark-b', name: 'Pull Shark (Bronze)',   icon: '🦈', desc: '2+ merged pull requests',                   script: 'scripts/pull-shark.sh 2' },
  { id: 'pullshark-s', name: 'Pull Shark (Silver)',   icon: '🦈', desc: '16+ merged pull requests',                  script: 'scripts/pull-shark.sh 16' },
  { id: 'pullshark-g', name: 'Pull Shark (Gold)',     icon: '🦈', desc: '128+ merged pull requests',                 script: 'scripts/pull-shark.sh 128' },
  { id: 'pair',        name: 'Pair Extraordinaire',   icon: '👥', desc: 'Merged a co-authored commit',               script: 'scripts/pair-extraordinaire.sh "Name" "email@example.com"' },
  { id: 'arctic',      name: 'Arctic Code Vault',     icon: '🧊', desc: 'Contributed to 2020 Archive Program',       script: null },
  { id: 'starstruck',  name: 'Starstruck',            icon: '⭐', desc: 'Created a repo with 16+ stars',             script: null },
];

const ROADMAP = [
  { day: 'Day 1',    tasks: ['Create GitHub repo', 'Push code', 'Open Codespace', 'Run setup.sh', 'Unlock Quick Draw + YOLO'] },
  { day: 'Day 2',    tasks: ['Create v1.0.0 release (Publicist)', 'Open 2 PRs and merge (Pull Shark Bronze)', 'Add co-author commit (Pair Extraordinaire)'] },
  { day: 'Week 1',   tasks: ['Merge 16 PRs total (Pull Shark Silver)', 'Share repo on social media', 'Add GitHub topic tags'] },
  { day: 'Week 2',   tasks: ['Write documentation', 'Add more tests', 'Create v1.1.0 release'] },
  { day: 'Month 1',  tasks: ['Merge 128 PRs (Pull Shark Gold)', 'Reach 16 stars (Starstruck)', 'Contribute to open source (Arctic Code Vault)'] },
];

function getGitHubUser() {
  try {
    return execSync('gh api user -q .login 2>/dev/null', { encoding: 'utf8' }).trim();
  } catch {
    return null;
  }
}

function printBadges() {
  const user = getGitHubUser();
  console.log(`\n🏅 Achievement Tracker — ${PROJECT}`);
  console.log('='.repeat(50));

  if (user) {
    console.log(`👤 GitHub User: ${user}`);
    console.log(`🔗 Profile: https://github.com/${user}\n`);
  } else {
    console.log('⚠️  Not authenticated (run: gh auth login)\n');
  }

  console.log('Badges to unlock:\n');
  BADGES.forEach((badge, i) => {
    const num = String(i + 1).padStart(2, ' ');
    console.log(`  ${num}. ${badge.icon} ${badge.name}`);
    console.log(`      ${badge.desc}`);
    if (badge.script) {
      console.log(`      → bash ${badge.script}`);
    } else {
      console.log(`      → Manual (see README)`);
    }
    console.log('');
  });

  console.log('Quick unlock all:');
  console.log('  bash scripts/unlock-all.sh\n');
}

function printRoadmap() {
  console.log(`\n🗺️  Day 1 → Month 1 Roadmap — ${PROJECT}`);
  console.log('='.repeat(50));
  ROADMAP.forEach(phase => {
    console.log(`\n📅 ${phase.day}:`);
    phase.tasks.forEach(t => console.log(`   ✦ ${t}`));
  });
  console.log('');
}

if (showRoadmap) {
  printRoadmap();
} else {
  printBadges();
}
