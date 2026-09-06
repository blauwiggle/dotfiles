#!/usr/bin/env bash
# claude-config-dir.sh <name> — give a second Claude Code config home
# (~/.claude-<name>, used via CLAUDE_CONFIG_DIR) the same rules, skills,
# hooks, plugins, CLAUDE.md and per-project memory as the main ~/.claude, by symlink, so one
# edit reaches every account. Existing real dirs are kept as <entry>.bak.
# settings.json is copied once (it holds permissions + hooks) if absent;
# .claude.json (the account login) is never touched.
set -eu
name=${1:?usage: claude-config-dir.sh <name>   (e.g. cc3 -> ~/.claude-cc3)}
main="$HOME/.claude"
dir="$HOME/.claude-$name"
mkdir -p "$dir"
for entry in CLAUDE.md hooks plugins rules skills; do
  src="$main/$entry"; dst="$dir/$entry"
  [ -e "$src" ] || { echo "skip $entry: $src does not exist"; continue; }
  if [ -L "$dst" ]; then
    [ "$(readlink "$dst")" = "$src" ] && { echo "ok   $entry -> $src"; continue; }
    rm "$dst"
  elif [ -e "$dst" ]; then
    mv "$dst" "$dst.bak" && echo "kept $entry as $entry.bak"
  fi
  ln -s "$src" "$dst" && echo "link $entry -> $src"
done
# Per-project memory (projects/<proj>/memory) is shared the same way: one
# memory across accounts, so a lesson learned under one token reaches the
# others. Session transcripts beside it stay per config dir.
for src in "$main"/projects/*/memory; do
  [ -d "$src" ] || continue
  proj=$(basename "$(dirname "$src")"); dst="$dir/projects/$proj/memory"
  if [ -L "$dst" ]; then
    [ "$(readlink "$dst")" = "$src" ] && continue
    rm "$dst"
  elif [ -d "$dst" ]; then
    rmdir "$dst" 2>/dev/null || { mv "$dst" "$dst.bak" && echo "kept $proj/memory as memory.bak"; }
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst" && echo "link $proj/memory -> $src"
done
if [ ! -e "$dir/settings.json" ]; then
  cp "$main/settings.json" "$dir/settings.json" && echo "copy settings.json from $main"
else
  echo "keep settings.json (exists; diff against $main/settings.json by hand)"
fi
