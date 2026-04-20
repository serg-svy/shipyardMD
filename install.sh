#!/bin/bash

# DevForge — Install Script
# Usage: curl -fsSL https://raw.githubusercontent.com/serg-svy/shipyardMD/main/install.sh | bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         DevForge Installer           ║${NC}"
echo -e "${BLUE}║   AI-Powered Development Framework   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# --- Check dependencies ---

check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo -e "${RED}✗ $1 is not installed.${NC} $2"
    exit 1
  else
    echo -e "${GREEN}✓ $1 found${NC}"
  fi
}

echo -e "${YELLOW}Checking dependencies...${NC}"
check_command git  "Install from https://git-scm.com"
check_command claude "Install Claude Code from https://claude.ai/code"
echo ""

# --- Ask for project folder name ---

read -p "Enter your project folder name (default: my-project): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-my-project}

if [ -d "$PROJECT_NAME" ]; then
  echo -e "${RED}✗ Folder '$PROJECT_NAME' already exists. Choose a different name.${NC}"
  exit 1
fi

# --- Clone DevForge ---

echo ""
echo -e "${YELLOW}Cloning DevForge into ./$PROJECT_NAME ...${NC}"
git clone https://github.com/serg-svy/shipyardMD.git "$PROJECT_NAME" --depth=1
cd "$PROJECT_NAME"

# Remove git history so developer starts fresh
rm -rf .git
git init
git add .
git commit -m "Initial commit from DevForge"

echo -e "${GREEN}✓ DevForge cloned and initialized${NC}"

# --- Copy .env.example to .env ---

if [ -f ".env.example" ]; then
  cp .env.example .env
  echo -e "${GREEN}✓ .env created from .env.example${NC}"
  echo -e "${YELLOW}  → Fill in your secrets in .env before starting${NC}"
fi

# --- Install workflow skills ---

echo ""
echo -e "${YELLOW}Installing workflow skills...${NC}"

SKILLS_DIR=".claude/skills"
mkdir -p "$SKILLS_DIR"

for skill in review ship qa security investigate; do
  if [ -d "skills/$skill" ]; then
    mkdir -p "$SKILLS_DIR/$skill"
    ln -sf "$(pwd)/skills/$skill/SKILL.md" "$SKILLS_DIR/$skill/SKILL.md"
    echo -e "${GREEN}✓ /$skill skill installed${NC}"
  fi
done

echo -e "${GREEN}✓ Skills ready: /review /ship /qa /security /investigate${NC}"

# --- Done ---

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        ShipyardMD is ready!          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "Your project: ${BLUE}./$PROJECT_NAME${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. cd $PROJECT_NAME"
echo "  2. claude ."
echo "  3. Answer Claude's 4 questions to start your project"
echo ""
echo -e "${YELLOW}Workflow skills available:${NC}"
echo "  /review    — code review before every PR"
echo "  /ship      — sync, test, commit, open PR, update CHANGELOG"
echo "  /qa [url]  — QA test on staging"
echo "  /security  — OWASP + STRIDE security audit"
echo "  /investigate [bug] — systematic root cause debugging"
echo ""
echo -e "${YELLOW}Security reminder:${NC}"
echo "  → Add your secrets to .env (never commit this file)"
echo "  → .gitignore already covers .env and common sensitive files"
echo ""
