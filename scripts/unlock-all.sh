#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   linkprobe — Achievement Unlocker     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

if ! gh auth status &>/dev/null; then
  echo -e "${RED}ERROR: Not authenticated with GitHub CLI.${NC}"
  echo "  Run: gh auth login"
  exit 1
fi

USER=$(gh api user -q .login)
echo -e "${GREEN}Authenticated as: $USER${NC}"
echo ""

echo "Choose an option:"
echo "  1) Quick Draw (open + close issue)"
echo "  2) YOLO (merge PR without review)"
echo "  3) Publicist (create v1.0.0 release)"
echo "  4) Pull Shark Bronze (2 PRs)"
echo "  5) Pull Shark Silver (16 PRs)"
echo "  6) Pull Shark Gold (128 PRs)"
echo "  7) Pair Extraordinaire"
echo "  8) Full Blast (all of the above, Bronze only)"
echo "  q) Quit"
echo ""
read -rp "Choice: " CHOICE

case "$CHOICE" in
  1) bash scripts/quickdraw.sh ;;
  2) bash scripts/yolo.sh ;;
  3) bash scripts/publicist.sh ;;
  4) bash scripts/pull-shark.sh 2 ;;
  5) bash scripts/pull-shark.sh 16 ;;
  6) bash scripts/pull-shark.sh 128 ;;
  7)
    read -rp "Co-author name: " CONAME
    read -rp "Co-author email: " COEMAIL
    bash scripts/pair-extraordinaire.sh "$CONAME" "$COEMAIL"
    ;;
  8)
    echo -e "${YELLOW}=== FULL BLAST MODE ===${NC}"
    bash scripts/quickdraw.sh
    bash scripts/yolo.sh
    bash scripts/publicist.sh
    bash scripts/pull-shark.sh 2
    read -rp "Co-author name: " CONAME
    read -rp "Co-author email: " COEMAIL
    bash scripts/pair-extraordinaire.sh "$CONAME" "$COEMAIL"
    echo -e "${GREEN}✅ All achievements triggered!${NC}"
    ;;
  q) echo "Bye!"; exit 0 ;;
  *) echo "Invalid choice"; exit 1 ;;
esac

echo ""
echo -e "${GREEN}Profile: https://github.com/$USER${NC}"
