#!/usr/bin/env bash

# This is for exporting dotfiles to my work computer, that unfortunately has JAMF
# on it, so I dont want to run a nix daemon. It is currently broken.

set -euo pipefail

TARBALL="${1:-$HOME/dotfiles-portable.tar.gz}"
EXPORT_DIR="$(mktemp -d)"
EXPORT_PATHS=(
    .config/nvim
    .config/starship.toml
    .config/zsh
    .config/git/config
    .config/tmux
    .zshrc
    .zprofile
)
#NAMESPACE="default"
#POD=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=blog -o jsonpath='{.items[0].metadata.name}')

trap 'rm -rf "$EXPORT_DIR"' EXIT

for path in "${EXPORT_PATHS[@]}"; do
    src="$HOME/$path"
    dest="$EXPORT_DIR/$path"
    
    [[ -e "$src" ]] || { echo "skip: $path"; continue; }
    
    mkdir -p "$(dirname "$dest")"
    cp -rL "$src" "$dest"
    echo "exported: $path"
done

echo -e "\n--- Nix store references (will break) ---"
if grep -rq '/nix/store' "$EXPORT_DIR" 2>/dev/null; then
    grep -rl '/nix/store' "$EXPORT_DIR" 2>/dev/null
    echo "^ Fix these before deploying"
else
    echo "None found"
fi

tar -czvf "$TARBALL" -C "$EXPORT_DIR" .
echo -e "\nCreated: $TARBALL ($(du -h "$TARBALL" | cut -f1))"

#kubectl cp "$TARBALL" "$NAMESPACE/$POD:/usr/share/nginx/html/dotfiles.tar.gz"

#echo "Upload complete"
