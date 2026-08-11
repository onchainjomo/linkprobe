#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
TS=$(date +%s)

echo -e "${GREEN}=== Quick Draw Achievement ===${NC}"
echo "Opens and closes a GitHub issue in under 5 minutes."
echo ""

# Auth check
if ! gh auth status &>/dev/null; then
  echo -e "${RED}ERROR: Not authenticated with GitHub CLI.${NC}"
  echo "  Run: gh auth login"
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [ -z "$REPO" ]; then
  echo -e "${RED}ERROR: Not in a GitHub repo. Push this repo first.${NC}"
  exit 1
fi

echo -e "${YELLOW}Repo: $REPO${NC}"
echo "Creating issue..."
ISSUE_URL=$(gh issue create --title "Quick Draw test issue [$TS]" --body "This issue will be closed immediately to unlock the Quick Draw achievement." --label "" 2>/dev/null | tail -1)
ISSUE_NUM=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')

echo -e "${GREEN}✓ Issue #$ISSUE_NUM created${NC}"
echo "Closing issue immediately..."
gh issue close "$ISSUE_NUM" --reason "not planned"

echo ""
echo -e "${GREEN}✅ Quick Draw unlocked!${NC}"
echo "Check your profile: https://github.com/$(gh api user -q .login)"
