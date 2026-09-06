# ~/.zshrc — interactive shell config (managed via dotfiles)

# Exports
[ -f ~/.config/secrets/azdo.zsh ] && source ~/.config/secrets/azdo.zsh

# ── Locale ──────────────────────────────────────────────
export LANG=en_US.UTF-8

# ── History ─────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share history across running sessions
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicate entries
setopt HIST_IGNORE_SPACE      # don't record commands starting with a space
setopt HIST_REDUCE_BLANKS     # trim superfluous blanks before saving
setopt HIST_VERIFY            # show history expansion before running
setopt INC_APPEND_HISTORY     # write as you go, not only at shell exit

# ── PATH (deduped, single source of truth) ──────────────
typeset -U path PATH          # keep PATH entries unique
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export BUN_INSTALL="$HOME/.bun"
path=(
  "$HOME/.local/bin"
  "$HOME/go/bin"
  "${KREW_ROOT:-$HOME/.krew}/bin"
  "$HOME/development/flutter/bin"
  "$HOME/.pub-cache/bin"
  "$HOME/.gem/bin"
  "$HOME/.jbang/bin"
  "$BUN_INSTALL/bin"
  "/opt/homebrew/opt/ruby/bin"
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  "$ANDROID_HOME/platform-tools"
  $path
)

export GOPRIVATE="github.com/basedcrew/*"

# ── Secrets (untracked; see ~/.zsh.secrets) ─────────────
[[ -f ~/.zsh.secrets ]] && source ~/.zsh.secrets

# ── Completions ─────────────────────────────────────────
# Cache external completions to files in fpath instead of forking a
# subshell on every startup. Delete ~/.cache/zsh/completions to refresh.
zsh_comp_dir="$HOME/.cache/zsh/completions"
[[ -d $zsh_comp_dir ]] || mkdir -p "$zsh_comp_dir"
fpath=("$zsh_comp_dir" "$HOME/.docker/completions" $fpath)
[[ -f $zsh_comp_dir/_docker  ]] || docker  completion zsh > "$zsh_comp_dir/_docker"  2>/dev/null
[[ -f $zsh_comp_dir/_kubectl ]] || kubectl completion zsh > "$zsh_comp_dir/_kubectl" 2>/dev/null

# bun completions
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"

# Single compinit: rebuild the dump at most once per 24h, otherwise
# load it fast with -C (skips the per-file security audit).
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# bash-style completions (terraform ships one)
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

zstyle ':completion:*' menu yes select

# ── Zinit plugin manager ────────────────────────────────
### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust
### End of Zinit's installer chunk

# Turbo-load plugins just after the prompt appears (lucid = quiet).
# syntax-highlighting MUST be listed last.
zinit wait lucid for \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  atload"bindkey '^[[A' history-substring-search-up; bindkey '^[[B' history-substring-search-down" \
      zsh-users/zsh-history-substring-search \
  zsh-users/zsh-syntax-highlighting

# ── Aliases ─────────────────────────────────────────────
alias ls='eza --long --all --no-permissions --no-filesize --no-user --no-time --git'
alias ll='eza --long --all --no-permissions --no-filesize --no-user --git --sort modified'
alias fzfp='fzf --preview "bat --style numbers --color always {}"'
alias cat='bat --paging never --theme DarkNeon --style plain'
alias k=kubectl
alias tf=terraform
alias bru="brew update && brew upgrade && brew cleanup && brew doctor"
alias x="exit"
alias ac="clear"
alias zz="source ~/.zshrc"
alias pip='pip3'
alias flur='flutter clean && flutter pub get && flutter run'
alias crossover-reset='bash -c "$(curl -fsSL https://raw.githubusercontent.com/Nygosaki/crossover-trial-renew/refs/heads/main/resetCrossoverTrial.sh)"'
alias gggg='go fmt ./...; go vet ./...; go test ./...; golangci-lint run ./...'
alias j!=jbang   # JBang
alias attestory-kv='npx wrangler kv key list --namespace-id b19d177b109a4ea3b663984676d7b4c4 --remote'

[ -f ~/.config/secrets/claude-tokens.zsh ] && source ~/.config/secrets/claude-tokens.zsh
alias claude1='CLAUDE_CODE_OAUTH_TOKEN="$CLAUDE_CODE_OAUTH_TOKEN_A" claude'
alias claude2='CLAUDE_CODE_OAUTH_TOKEN="$CLAUDE_CODE_OAUTH_TOKEN_B" claude'

alias cc1='claude'  # Hauptaccount + Brain = echter Default ~/.claude
alias cc2='CLAUDE_CONFIG_DIR=~/.claude-cc2 claude'

# ── Tool initialization ─────────────────────────────────
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
command -v rbenv >/dev/null && eval "$(rbenv init - zsh)"  # not on the server subset

# thefuck is slow (spawns Python) — lazy-load on first use instead of
# paying the cost on every shell start.
fuck() {
  unset -f fuck
  eval "$(thefuck --alias)"
  fuck "$@"
}

# Devbox (disabled)
# DEVBOX_NO_PROMPT=true
# eval "$(devbox global shellenv --init-hook)"

# Live-Ansicht laufender Claude-Sessions im aro-workshop (Text + Tool-Aufrufe)
watch-claude() {
  tail -f "$(command ls -t ~/.claude/projects/*aro-workshop*/*.jsonl | head -1)" \
  | jq -r --unbuffered 'select(.type=="assistant") | .message.content[]? |
      if .type=="text" then .text
      elif .type=="tool_use" then "▸ " + .name + ": " + ((.input.command // .input.file_path // .input.description // "") | tostring | split("\n")[0] | .[0:120])
      else empty end'
}

# zoxide must be initialized at the very end of this file.
eval "$(zoxide init --cmd cd zsh)"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/michi/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
