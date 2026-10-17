_nh verb host:
    #!/usr/bin/env sh
    set -e
    [ -z "{{ host }}" ] && exec nh os {{ verb }} {{ nixops_path }} --diff always
    r=liana@{{ host }}.{{ mgmt }}
    exec nh os {{ verb }} {{ nixops_path }} --diff always -H {{ host }} --target-host "$r" --build-host "$r"

# Build and diff, local or remote
[group('deploy')]
build host='': (_nh "build" host)

# Build and switch, local or remote
[group('deploy')]
switch host='': (_nh "switch" host)

# Wipe and install host with the cwd included as --extra-files
[confirm("wipe + install now?")]
[group('deploy')]
install host ip check='':
    #!/usr/bin/env sh
    set -eu
    d={{ invocation_directory() }}
    die() { echo "$*" >&2; exit 1; }
    k=$d/var/lib/sops-nix/key.txt
    [ -f "$k" ] || die "missing $k"
    case '{{ check }}' in
    '') ;;
    --check)
        f=$(nix eval --raw {{ nixops_path }}#nixosConfigurations.{{ host }}.config.sops.defaultSopsFile)
        h=$(env -i PATH="$PATH" HOME="$d" SOPS_AGE_KEY_FILE="$k" sops -d --extract '["users"]["liana"]["password"]' "$f" 2>/dev/null) \
            || die "key.txt cannot decrypt $f"
        trap 'stty echo' EXIT
        stty -echo
        printf 'liana@{{ host }} password: '
        read -r p
        stty echo
        echo
        [ "$(printf %s "$p" | mkpasswd -s -S "$h" 2>/dev/null)" = "$h" ] || die "password does not match $f"
        ;;
    *) die "unknown arg: {{ check }}" ;;
    esac
    nix run nixpkgs#nixos-anywhere -- --flake {{ nixops_path }}#{{ host }} --extra-files "$d" root@{{ ip }}
