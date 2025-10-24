#!/usr/bin/env bash
set -euo pipefail

APP_DIR=/var/www/strivo
cd "$APP_DIR"

echo "== Pull latest =="
git fetch --all
git reset --hard origin/main

echo "== Bundle =="
export PATH="$HOME/.rbenv/bin:$PATH"; eval "$($HOME/.rbenv/bin/rbenv init - bash)"
bundle config set path "vendor/bundle"
bundle install --without development test --deployment

echo "== DB migrate =="
RAILS_ENV=production bundle exec rails db:migrate

echo "== Assets =="
RAILS_ENV=production bundle exec rails assets:precompile

echo "== Restart Puma =="
sudo systemctl restart puma
echo "Done."
