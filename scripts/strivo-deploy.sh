#!/bin/bash
set -e

APP_DIR="/var/www/strivo"
BRANCH="main"
REPO_SSH="git@github.com:rickvantwesteinde/strivo-platform.git"

echo "[STRIVO-DEPLOY] 🚀 $(date)"

# rbenv in PATH (user 'strivo')
if [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$($HOME/.rbenv/bin/rbenv init - bash)"
fi

# Eerste keer: clone via deploy key
if [ ! -d "$APP_DIR/.git" ]; then
  echo "[STRIVO-DEPLOY] Initializing repo..."
  mkdir -p "$APP_DIR"
  # clone as current user, using the per-user deploy key
  GIT_SSH_COMMAND="ssh -i $HOME/.ssh/github_deploy -o IdentitiesOnly=yes" \
    git clone "$REPO_SSH" "$APP_DIR"
fi

# Markeer repo als safe (tegen 'dubious ownership')
git config --global --add safe.directory "$APP_DIR" || true

echo "[STRIVO-DEPLOY] Pulling latest code from $BRANCH..."
cd "$APP_DIR"
GIT_SSH_COMMAND="ssh -i $HOME/.ssh/github_deploy -o IdentitiesOnly=yes" \
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

echo "[STRIVO-DEPLOY] DB migrate + assets..."
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake assets:precompile

echo "[STRIVO-DEPLOY] Restart services (best effort)..."
systemctl restart puma || true
systemctl restart nginx || true

echo "[STRIVO-DEPLOY] ✅ Done"
