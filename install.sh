#!/bin/bash
# Fresh-machine install. Run from anywhere; needs your sudo password once (Homebrew).
#   BREWFILE=Brewfile.server bash ~/dotfiles/install.sh   # server subset (Mac mini)
#   bash ~/dotfiles/install.sh                            # full (MacBook)
set -e
cd "$(dirname "$0")"
touch ~/.hushlogin

command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# https://github.com/zdharma-continuum/zinit?tab=readme-ov-file#install
[ -d ~/.local/share/zinit/zinit.git ] || bash -c "$(curl --fail --show-error --silent \
    --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

brew bundle --file="./${BREWFILE:-Brewfile}"

defaults import com.apple.dock ./defaults/com.apple.dock.plist
defaults import com.apple.finder ./defaults/com.apple.finder.plist
defaults import NSGlobalDomain ./defaults/NSGlobalDomain.plist

killall Dock
killall Finder
killall SystemUIServer
