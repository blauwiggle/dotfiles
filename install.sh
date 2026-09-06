#!/bin/bash
# Fresh-machine install. Needs your sudo password once (Homebrew). Everything is logged to ~/install.log.
#   BREWFILE=Brewfile.server VERBOSE=1 bash ~/dotfiles/install.sh   # server subset (Mac mini), every command echoed
#   bash ~/dotfiles/install.sh                                      # full (MacBook)
set -e
cd "$(dirname "$0")"
exec > >(tee -a ~/install.log) 2>&1
[ -n "$VERBOSE" ] && set -x
step() { printf '\n==> [%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

step "start: $(hostname -s), brewfile=${BREWFILE:-Brewfile}"
touch ~/.hushlogin

step "homebrew"
command -v brew >/dev/null && echo "already installed: $(brew --version | head -1)" \
  || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew --version | head -1

step "zinit"
[ -d ~/.local/share/zinit/zinit.git ] && echo "already installed" \
  || NO_INPUT=1 NO_EDIT=1 bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

step "brew bundle --file=./${BREWFILE:-Brewfile}"
brew trust hashicorp/tap 2>/dev/null || true   # Homebrew 6 refuses untrusted taps; a no-op on older brews
brew bundle ${VERBOSE:+--verbose} --file="./${BREWFILE:-Brewfile}"

step "macOS defaults"
defaults import com.apple.dock ./defaults/com.apple.dock.plist
defaults import com.apple.finder ./defaults/com.apple.finder.plist
defaults import NSGlobalDomain ./defaults/NSGlobalDomain.plist
killall Dock Finder SystemUIServer 2>/dev/null || true

step "done"
