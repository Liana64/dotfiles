# @desc: Shell aliases (rust-tool replacements)
{...}: {
  flake.modules.homeManager.aliases = {lib, ...}: let
    editors = {
      vi = "nvim";
      vim = "nvim";
      n = "nvim";
    };

    ls = {
      l = "eza -la --git --group-directories-first";
      ll = "eza -la --git --group-directories-first";
      ls = "eza";
      l1 = "eza -1";
    };

    grep = {
      ug = "rg";
      grep = "rg";
      egrep = "rg -E";
      fgrep = "rg -F";
      xzgrep = "rg -z";
      xzegrep = "rg -zE";
      xzfgrep = "rg -zF";
    };

    personal = {
      k = "kubectl";
      dotfiles = "n ~/.dotfiles";
      xclip = "wl-copy";
      clip = "wl-copy";
      thisip = "curl ifconfig.me -j";
      weather = "curl wttr.in/Chicago";
    };

    tasks = {
      # Open on the Today view (Todoist-style home screen).
      tt = "taskwarrior-tui -r today";
      # Snooze a task out of view until a wait date (default tomorrow): snooze <id> [when]
      snooze = "task-snooze";
      # AI task store — separate db from human tasks (see todo skill). ai.taskrc
      # points at the AI db, runs context-free, and clears default.project.
      ai-task = "tw rc:$HOME/.config/task/ai.taskrc";
      ai-task-tui = "taskwarrior-tui --taskrc $HOME/.config/task/ai.taskrc";
    };

    nixos = {
      gc = "nix-collect-garbage -d";
    };

    containers = {
      claw = "kubectl exec -it deploy/claude-clode -- claude";
      blog = "kubectl rollout restart deployment blog -n default";
    };

    rust-tools = {
      tree = "eza --tree";

      # This makes cat require "cat -p" for standard output, otherwise it gets piped to less
      cat = "bat";
      catp = "bat -p";

      df = "duf";
      diff = "delta";
      du = "dust";

      top = "btop";
      htop = "btop";
      neofetch = "fastfetch";

      nmap = "rustscan";
    };

    networking = {
      fastping = "ping -c 100 -i 0.2";
      ports = "ss -tunapl";
      listening = "ss -tlnp";
      netstat = "ss";
    };

    utility = {
      bc = "bc -l";
      h = "history";
      j = "jobs -l";
      uu = "uuidgen -r | tr '[:lower:]' '[:upper:]'";
      gpg-encrypt = "gpg -c --no-symkey-cache --cipher-algo=AES256";
      gpg-decrypt = "gpg -d";
    };

    git = {
      g = "git";
      gl = "git pull";
      gd = "git diff";
    };

    darwin = {
      flushdns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
    };

    aliases = editors // ls // grep // personal // tasks // nixos // containers // rust-tools // networking // utility // git // darwin;

    helpText = lib.concatStringsSep "\\n" (
      lib.mapAttrsToList (name: value: "  ${name} = ${value}") aliases
    );
  in {
    programs.bash.shellAliases = aliases // {aliases = "echo -e '${helpText}'";};
    programs.zsh.shellAliases = aliases // {aliases = "echo -e '${helpText}'";};
  };
}
