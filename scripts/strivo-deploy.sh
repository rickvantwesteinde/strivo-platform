#!/bin/bash
set -e

APP_DIR="/var/www/strivo"
BRANCH="main"
REPO_URL="https://github.com/rickvantwesteinde/strivo-platform.git"

echo "[STRIVO-DEPLOY] 🚀 $(date)"

# rbenv in PATH (user 'strivo')
if [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$($HOME/.rbenv/bin/rbenv init - bash)"
fi

# First time: clone from public repo
if [ ! -d "$APP_DIR/.git" ]; then
  echo "[STRIVO-DEPLOY] Initializing repo..."
  mkdir -p "$APP_DIR"
  # clone from public repository (no authentication needed)
  git clone "$REPO_URL" "$APP_DIR"
fi

# Mark repo as safe (against 'dubious ownership')
git config --global --add safe.directory "$APP_DIR" || true

echo "[STRIVO-DEPLOY] Pulling latest code from $BRANCH..."
cd "$APP_DIR"
# Load .env into process env
set -a
[ -f "$APP_DIR/.env" ] && . "$APP_DIR/.env"
set +a
git fetch origin "$BRANCH"
git reset --hard "origin/$BRANCH"

echo "[STRIVO-DEPLOY] Bundler install..."
bundle config set --local path 'vendor/bundle'
bundle config set without 'development test'
bundle install

echo "[STRIVO-DEPLOY] Node deps..."
corepack enable || true
command -v yarn >/dev/null 2>&1 || npm -g i yarn || true
[ -f package.json ] && yarn install --frozen-lockfile || true

# Ensure env
: "${RAILS_ENV:=production}"
export RAILS_ENV
echo "[STRIVO-DEPLOY] On commit: $(git rev-parse --short HEAD)"

echo "[STRIVO-DEPLOY] DB migrate + assets..."
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake assets:precompile

echo "[STRIVO-DEPLOY] Restart services (best effort)..."
systemctl restart puma || true
systemctl restart nginx || true

echo "[STRIVO-DEPLOY] ✅ Done"
