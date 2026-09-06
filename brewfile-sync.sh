#!/bin/sh
# Dump this machine's installed Homebrew state into Brewfile and push it when it changed.
# Runs weekly from launchd (launchd/com.blauwiggle.brewfile-sync.plist); safe to run by hand.
set -eu
export PATH="/opt/homebrew/bin:/usr/bin:/bin"
cd "$(dirname "$0")"
brew bundle dump --force --file=Brewfile
git add Brewfile
git diff --cached --quiet && exit 0
git commit -qm "chore: brewfile from $(hostname -s)'s installed state"
git push -q origin HEAD
