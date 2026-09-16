#!/bin/sh
# Converge this machine onto Brewfile.server: pull the manifest, install what is missing, never upgrade.
# The counterpart of brewfile-sync.sh (which records state); this one enforces the declared state.
# Runs daily from launchd (launchd/com.blauwiggle.brewfile-apply.plist) on the Mac mini; safe to run by hand.
set -eu
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
cd "$(dirname "$0")"
echo "==> $(date -u +%Y-%m-%dT%H:%M:%SZ) $(hostname -s)"
# A failed pull (dirty tree, offline) must not stop the install from the manifest already here.
git pull -q --ff-only || echo "warn: git pull failed; applying Brewfile.server at $(git rev-parse --short HEAD)"
brew trust hashicorp/tap 2>/dev/null || true
brew bundle check --no-upgrade --file=Brewfile.server && exit 0
brew bundle install --no-upgrade --file=Brewfile.server
