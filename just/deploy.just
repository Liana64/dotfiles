_nh verb host:
    #!/usr/bin/env sh
    set -e
    [ -z "{{ host }}" ] && exec nh os {{ verb }} /nix/dotfiles --diff always
    r=liana@{{ host }}.{{ mgmt }}
    exec nh os {{ verb }} /nix/dotfiles --diff always -H {{ host }} --target-host "$r" --build-host "$r"

# Build and diff, local or remote
[group('deploy')]
build host='': (_nh "build" host)

# Build and switch, local or remote
[group('deploy')]
switch host='': (_nh "switch" host)

# Wipe and install host with the cwd included as --extra-files
[confirm("wipe + install now?")]
[group('deploy')]
install host ip:
    #!/usr/bin/env sh
    set -e
    case {{ invocation_directory() }} in /run/user/*/ceremony.*) ;; *) echo "run from a ceremony dir" >&2; exit 1 ;; esac
    nix run nixpkgs#nixos-anywhere -- --flake /nix/dotfiles#{{ host }} --extra-files {{ invocation_directory() }} root@{{ ip }}
