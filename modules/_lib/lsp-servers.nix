# @desc: bubblewrap-confined language servers (not imported; consumed by shell/lsp.nix)
{pkgs}: let
  inherit (pkgs) lib;

  confine = {
    name,
    package,
    net ? false,
    homePaths ? [],
  }: let
    binds = lib.concatMapStrings (p: ''--bind "$HOME/${p}" "$HOME/${p}"'') homePaths;
  in
    pkgs.writeShellScriptBin name ''
      set -eu
      # bind the repo, not $PWD: servers started from a subdir still need the whole project
      root=$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || printf '%s' "$PWD")
      case $root in
        "$HOME" | /)
          printf '${name}: refusing to sandbox %s\n' "$root" >&2
          exit 1
          ;;
      esac
      ${lib.concatMapStrings (p: ''mkdir -p "$HOME/${p}"'' + "\n") homePaths}
      exec ${pkgs.bubblewrap}/bin/bwrap \
        --ro-bind /nix/store /nix/store \
        --ro-bind /etc /etc \
        --ro-bind /run/current-system/sw /run/current-system/sw \
        --ro-bind-try "$HOME/.nix-profile" "$HOME/.nix-profile" \
        --proc /proc --dev /dev --tmpfs /tmp \
        --bind "$root" "$root" --chdir "$PWD"${binds} \
        --unshare-all ${lib.optionalString net "--share-net"} \
        --new-session --die-with-parent \
        ${package}/bin/${name} "$@"
    '';
in
  # $HOME is never bound, so ~/.ssh and ~/.gnupg are invisible to build scripts,
  # proc macros and anything else a server executes out of the project
  lib.mapAttrs (name: args:
    confine ({
        inherit name;
        package = pkgs.${name};
      }
      // args)) {
    nil = {};
    nixd = {};
    marksman = {};
    lua-language-server = {homePaths = [".cache/lua-language-server"];};
    # cargo re-downloads the whole crates.io index on every start without its home
    rust-analyzer = {
      net = true;
      homePaths = [".cargo"];
    };
  }
