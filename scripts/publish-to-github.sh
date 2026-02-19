#!/usr/bin/env bash
# Публикация проекта в GitHub: https://github.com/qmish/Starter-Pack
# Требования: git, при необходимости GitHub CLI (gh).
# Выполняйте в корне проекта (StarterPack).

set -e
REPO_URL="https://github.com/qmish/Starter-Pack.git"
REMOTE="origin"

if [ ! -d .git ]; then
  echo "Инициализация git-репозитория..."
  git init
  git branch -M main
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "Добавление файлов и первый коммит..."
  git add -A
  git commit -m "chore: initial commit - SigNoz Starter Pack"
elif ! git log -1 &>/dev/null; then
  git add -A
  git commit -m "chore: initial commit - SigNoz Starter Pack" --allow-empty
fi

if ! git remote | grep -q "^${REMOTE}$"; then
  echo "Добавление удалённого репозитория ${REPO_URL}..."
  git remote add $REMOTE $REPO_URL
else
  CURRENT=$(git remote get-url $REMOTE 2>/dev/null || true)
  if [ "$CURRENT" != "$REPO_URL" ]; then
    git remote set-url $REMOTE $REPO_URL
  fi
fi

echo ""
echo "Создайте репозиторий на GitHub (если ещё не создан):"
echo "  1. Откройте https://github.com/new"
echo "  2. Repository name: Starter-Pack"
echo "  3. Public, без README/.gitignore"
echo "  4. Create repository"
echo ""
echo "Или: gh repo create qmish/Starter-Pack --public --source=. --remote=origin --push"
echo ""
read -p "Запушить в origin/main сейчас? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[yY]$ ]]; then
  git push -u $REMOTE main
  echo "Готово. Репозиторий: https://github.com/qmish/Starter-Pack"
else
  echo "Для ручной отправки: git push -u origin main"
fi
