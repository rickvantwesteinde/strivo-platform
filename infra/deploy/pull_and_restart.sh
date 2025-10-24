#!/usr/bin/env bash
set -euo pipefail

APP_DIR=/var/www/strivo
cd "$APP_DIR"

# rbenv + environment
export PATH="$HOME/.rbenv/bin:$PATH"; eval "$($HOME/.rbenv/bin/rbenv init - bash)"

# Laad .env zodat SECRET_KEY_BASE e.d. beschikbaar zijn
set -a
[ -f .env ] && . ./.env
set +a
: "\${SECRET_KEY_BASE:?SECRET_KEY_BASE missing}"

echo "== Pull latest =="
git fetch --all
git reset --hard origin/main

echo "== Bundle =="
bundle config set path "vendor/bundle"
bundle config set deployment true
bundle config set without "development test"
bundle install

echo "== DB migrate =="
RAILS_ENV=production bundle exec rails db:migrate

echo "== Assets =="
RAILS_ENV=production bundle exec rails assets:precompile

echo "== Restart Puma =="
sudo -n /usr/bin/systemctl restart puma
echo "Done."
