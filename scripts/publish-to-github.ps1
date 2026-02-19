# Публикация проекта в GitHub: https://github.com/qmish/Starter-Pack
# Требования: git, при необходимости GitHub CLI (gh).
# Выполняйте в корне проекта (StarterPack).

$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/qmish/Starter-Pack.git"
$RemoteName = "origin"

if (-not (Test-Path ".git")) {
    Write-Host "Инициализация git-репозитория..."
    git init
    git branch -M main
}

$status = git status --porcelain
if ($status) {
    Write-Host "Добавление файлов и первый коммит..."
    git add -A
    git commit -m "chore: initial commit - SigNoz Starter Pack"
} else {
    $log = git log -1 2>$null
    if (-not $log) {
        git add -A
        git commit -m "chore: initial commit - SigNoz Starter Pack" --allow-empty
    }
}

$remotes = git remote 2>$null
if ($remotes -notcontains $RemoteName) {
    Write-Host "Добавление удалённого репозитория $RepoUrl ..."
    git remote add $RemoteName $RepoUrl
} else {
    $url = git remote get-url $RemoteName 2>$null
    if ($url -ne $RepoUrl) {
        git remote set-url $RemoteName $RepoUrl
    }
}

Write-Host ""
Write-Host "Создайте репозиторий на GitHub (если ещё не создан):"
Write-Host "  1. Откройте https://github.com/new"
Write-Host "  2. Repository name: Starter-Pack"
Write-Host "  3. Public, без README/.gitignore (проект уже есть локально)"
Write-Host "  4. Create repository"
Write-Host ""
Write-Host "Или через GitHub CLI:"
Write-Host "  gh repo create qmish/Starter-Pack --public --source=. --remote=origin --push"
Write-Host ""
$push = Read-Host "Запушить в origin/main сейчас? (y/n)"
if ($push -eq "y" -or $push -eq "Y") {
    git push -u $RemoteName main
    Write-Host "Готово. Репозиторий: https://github.com/qmish/Starter-Pack"
} else {
    Write-Host "Для ручной отправки выполните: git push -u origin main"
}
