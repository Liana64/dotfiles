{ pkgs, lib, ... }:
let
  editors = {
    vi = "nvim";
    vim = "nvim";
    n = "nvim";
  };

  ls = {
    l = "eza -la --git --group-directories-first";
    ll ="eza -la --git --group-directories-first";
    ls ="eza";
    l1 ="eza -1";
  };

  grep = {
    ug ="rg";
    grep ="rg";
    egrep ="rg -E";
    fgrep = "rg -F";
    xzgrep ="rg -z";
    xzegrep ="rg -zE";
    xzfgrep ="rg -zF";
  };

  personal = {
    k = "kubectl";
    dotfiles = "n ~/.dotfiles";
    xclip = "wl-copy";
    clip = "wl-copy";
    myip = "curl ifconfig.me -j";
    weather = "curl wttr.in/Chicago";
  };
  
  nixos = {
    nixy = "sudo nixos-rebuild switch --flake ~/.dotfiles#$(hostname | cut -d '.' -f1)";
    hms = "nix run home-manager/master -- switch --flake ~/.dotfiles#$(whoami)@$(hostname | cut -d '.' -f1)";
    gc = "nix-collect-garbage -d";
  };

  containers = {
    sec-tools = "kubectl exec -it deploy/sec-tools -- zsh";
    blog = "kubectl rollout restart deployment blog -n default";
  };

  rust-tools = {
    curl = "xh";
    tree = "eza --tree";

    # This makes cat require "cat -p" for standard output, otherwise it gets piped to less
    cat = "bat";
    catp = "bat -p";

    df = "duf";
    diff = "delta";
    du = "dust";

    find = "fd --";

    top = "btop";
    htop = "btop";
    neofetch = "fastfetch";

    # Beware, this breaks the "ps aux" command, use "\ps aux" if needed
    ps = "procs";
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
    uu = "uuidgen -x | tr '[:lower:]' '[:upper:]'";
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

  aliases = editors // ls // grep // personal // nixos // containers // rust-tools // networking // utility // git // darwin;
  
  helpText = lib.concatStringsSep "\\n" (
    lib.mapAttrsToList (name: value: "  ${name} = ${value}") aliases
  );
in
{
  programs.bash.shellAliases = aliases // { aliases = "echo -e '${helpText}'"; };
  programs.zsh.shellAliases = aliases // { aliases = "echo -e '${helpText}'"; };
}
