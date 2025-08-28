touch .hushlogin

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# https://github.com/zdharma-continuum/zinit?tab=readme-ov-file#install
bash -c "$(curl --fail --show-error --silent \
    --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

brew bundle --file=./Brewfile

defaults import com.apple.dock ./defaults/com.apple.dock.plist
defaults import com.apple.finder ./defaults/com.apple.finder.plist
defaults import NSGlobalDomain ./defaults/NSGlobalDomain.plist

killall Dock
killall Finder
killall SystemUIServer
