#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
TS=$(date +%s)
BRANCH="yolo-$TS"

echo -e "${GREEN}=== YOLO Achievement ===${NC}"
echo "Creates a branch, opens a PR, and merges without review."
echo ""

if ! gh auth status &>/dev/null; then
  echo -e "${RED}ERROR: Not authenticated. Run: gh auth login${NC}"; exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [ -z "$REPO" ]; then
  echo -e "${RED}ERROR: Not in a GitHub repo.${NC}"; exit 1
fi

echo -e "${YELLOW}Repo: $REPO${NC}"

git checkout -b "$BRANCH"
echo "# YOLO merge [$TS]" >> YOLO.md
git add YOLO.md
git commit -m "chore: yolo merge [$TS]"
git push origin "$BRANCH"

PR_URL=$(gh pr create --title "YOLO merge [$TS]" --body "Merging without review to unlock YOLO achievement." --head "$BRANCH")
PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')

echo -e "${GREEN}✓ PR #$PR_NUM created${NC}"
sleep 2
gh pr merge "$PR_NUM" --merge --delete-branch

git checkout main 2>/dev/null || git checkout master
git pull

echo ""
echo -e "${GREEN}✅ YOLO achievement unlocked!${NC}"
echo "Check: https://github.com/$(gh api user -q .login)"
