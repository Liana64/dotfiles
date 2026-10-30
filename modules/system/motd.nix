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

    motd = pkgs.writeShellApplication {
      name = "motd";
      runtimeInputs = [pkgs.coreutils pkgs.systemd];
      text = ''
        gen='?'
        for link in /nix/var/nix/profiles/system-*-link; do
          if [[ $link -ef /run/current-system ]]; then
            gen=''${link##*/system-}
            gen=''${gen%-link}
          fi
        done

        read -r up _ < /proc/uptime
        up=''${up%.*}
        d=$((up / 86400)) h=$((up % 86400 / 3600)) m=$((up % 3600 / 60))
        if ((d > 0)); then up="''${d}d ''${h}h"; else up="''${h}h ''${m}m"; fi

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
        printf ' \e[2m◆\e[0m nixos %s · gen %s · %s\n' ${config.system.nixos.release} "$gen" ${rev}
        printf ' %s · up %s\n\n' "$status" "$up"
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
