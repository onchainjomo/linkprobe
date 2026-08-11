#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${GREEN}=== Setting up linkprobe ===${NC}"

# Check Node.js
if ! command -v node &>/dev/null; then
  echo -e "${RED}ERROR: Node.js not found. Install Node 20+: https://nodejs.org${NC}"
  exit 1
fi

NODE_VER=$(node -e "process.exit(parseInt(process.versions.node) < 20 ? 1 : 0)" 2>/dev/null && echo "ok" || echo "old")
if [ "$NODE_VER" = "old" ]; then
  echo -e "${YELLOW}WARNING: Node.js 20+ recommended. Current: $(node --version)${NC}"
fi

# Check gh CLI
if ! command -v gh &>/dev/null; then
  echo -e "${YELLOW}WARNING: GitHub CLI not found.${NC}"
  echo "  Install: https://cli.github.com"
  echo "  Then run: gh auth login"
else
  echo -e "${GREEN}✓ GitHub CLI found: $(gh --version | head -1)${NC}"
fi

# Install dependencies
if [ -f package.json ]; then
  echo "Installing npm dependencies..."
  npm install --silent
  echo -e "${GREEN}✓ Dependencies installed${NC}"
fi

# Make scripts executable
chmod +x scripts/*.sh 2>/dev/null || true
echo -e "${GREEN}✓ Scripts made executable${NC}"

echo ""
echo -e "${GREEN}Setup complete! Try:${NC}"
echo "  npm start          # run the tool"
echo "  npm run tracker    # check achievement progress"
echo "  bash scripts/unlock-all.sh  # unlock GitHub achievements"
