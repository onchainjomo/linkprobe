#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${GREEN}=== Publicist Achievement ===${NC}"
echo "Creates a v1.0.0 GitHub Release."
echo ""

if ! gh auth status &>/dev/null; then
  echo -e "${RED}ERROR: Not authenticated. Run: gh auth login${NC}"; exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [ -z "$REPO" ]; then
  echo -e "${RED}ERROR: Not in a GitHub repo.${NC}"; exit 1
fi

echo -e "${YELLOW}Repo: $REPO${NC}"

# Tag and push
git tag -a v1.0.0 -m "Release v1.0.0" 2>/dev/null || git tag -f v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0 --force

# Create release
gh release create v1.0.0 \
  --title "v1.0.0 — Initial Release" \
  --notes "## What's New
First public release of linkprobe.

### Features
- See README.md for full feature list

### Installation
\`\`\`bash
git clone https://github.com/$REPO.git
cd linkprobe && npm install
\`\`\`" \
  --latest

echo ""
echo -e "${GREEN}✅ Publicist achievement unlocked!${NC}"
echo "Release: https://github.com/$REPO/releases/tag/v1.0.0"
echo "Check: https://github.com/$(gh api user -q .login)"
