# @desc: SSH login banner: host, generation, health, commands
{...}: {
  flake.modules.nixos.motd = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.motd;
    width = lib.foldl' lib.max 0 (map (c: lib.stringLength (lib.head c)) cfg.commands);
    row = c: ''printf ' \e[1m%-${toString width}s\e[0m   \e[2m%s\e[0m\n' ${lib.escapeShellArgs c}'';
    rev = inputs.self.shortRev or inputs.self.dirtyShortRev or "unknown";
    released = lib.substring 1 8 config.system.nixos.versionSuffix;

    motd = pkgs.writeShellApplication {
      name = "motd";
      runtimeInputs = [pkgs.coreutils pkgs.systemd];
      text = ''
        now=$(date +%s)
        span() {
          local s=$((now - $1))
          if ((s >= 86400)); then echo "$((s / 86400))d"
          elif ((s >= 3600)); then echo "$((s / 3600))h"
          else echo "$((s / 60))m"; fi
        }

        gen='?' deployed='?'
        for link in /nix/var/nix/profiles/system-*-link; do
          if [[ $link -ef /run/current-system ]]; then
            gen=''${link##*/system-}
            gen=''${gen%-link}
            deployed="$(span "$(stat -c %Y "$link")") old"
          fi
        done

        age=$(((now - $(date -d ${released} +%s)) / 86400))
        released="''${age}d old"
        if ((age > 30)); then released=$'\e[33m'"$released"$'\e[0m'; fi

        read -r up _ < /proc/uptime
        up=''${up%.*}
        d=$((up / 86400)) h=$((up % 86400 / 3600)) m=$((up % 3600 / 60))
        if ((d > 0)); then up="''${d}d ''${h}h"; else up="''${h}h ''${m}m"; fi
        for p in kernel initrd kernel-modules; do
          if [[ $(readlink /run/booted-system/$p) != $(readlink /run/current-system/$p) ]]; then
            up+=$' · \e[33mreboot pending\e[0m'
            break
          fi
        done

        alerts=()
        for f in /var/lib/audit-wall/alerts/*; do
          if [[ -s $f ]]; then alerts+=("''${f##*/}"); fi
        done

        state=$(systemctl is-system-running || true)
        case $state in
          running) status=$'\e[32m●\e[0m healthy' ;;
          starting | initializing) status=$'\e[33m●\e[0m starting' ;;
          *)
            status=$'\e[31m●\e[0m '"$state"
            mapfile -t failed < <(systemctl --failed --plain --no-legend --no-pager | cut -d' ' -f1)
            if ((''${#failed[@]})); then
              failed=("''${failed[@]%.service}")
              list=$(printf '%s, ' "''${failed[@]:0:3}")
              list=''${list%, }
              if ((''${#failed[@]} > 3)); then list+=" +$((''${#failed[@]} - 3))"; fi
              status+=" · ''${#failed[@]} failed: $list"
            fi
            ;;
        esac

        printf '\n \e[1;7m %s \e[0m  %s\n\n' ${lib.escapeShellArgs [config.networking.hostName cfg.description]}
        printf ' \e[2m◆\e[0m nixos %s (%s) · gen %s · %s (%s)\n' ${config.system.nixos.release} "$released" "$gen" ${rev} "$deployed"
        printf ' %s · up %s\n' "$status" "$up"
        if ((''${#alerts[@]})); then printf ' \e[31m●\e[0m alerts: %s\n' "''${alerts[*]}"; fi
        ${lib.concatLines cfg.status}
        echo
        ${lib.concatMapStringsSep "\n" row cfg.commands}
        echo
      '';
    };
  in {
    options.motd = {
      description = lib.mkOption {
        type = lib.types.str;
        description = "Host role shown beside the hostname.";
      };
      commands = lib.mkOption {
        type = lib.types.listOf (lib.types.listOf lib.types.str);
        default = [];
        description = "[command description] rows, in display order.";
      };
      status = lib.mkOption {
        type = lib.types.listOf lib.types.lines;
        default = [];
        description = "Shell snippets printing extra status lines below health.";
      };
    };

    config = {
      motd.commands = lib.mkAfter [
        ["systemctl --failed" "degraded units"]
        ["journalctl -b -p err" "this boot's errors"]
      ];
      environment.systemPackages = [motd];
      environment.loginShellInit = ''
        [ -t 1 ] && [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX$STY" ] && [ ! -e ~/.hushlogin ] && motd
      '';
    };
  };
}
