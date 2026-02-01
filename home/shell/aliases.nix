{ pkgs, lib, ... }:
let
  editors = {
    vi = "nvim";
    vim = "nvim";
    n = "nvim";
  };

  personal = {
    l = "eza -la --git";
    k = "kubectl";
    dotfiles = "n ~/.dotfiles";
    xclip = "wl-copy";
    clip = "wl-copy";
    myip = "curl ifconfig.me -j";
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
    ls = "eza -la --git";
    tree = "eza --tree";
    cat = "bat";
    df = "duf";
    diff = "delta";
    du = "dust";
    find = "fd";
    grep = "rg";
    top = "btop";
    htop = "btop";
    neofetch = "fastfetch";
    ps = "procs";
    nmap = "rustscan";
  };

  networking = {
    ports = "ss -tunapl";
    fastping = "ping -c 100 -i 0.2";
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

  aliases = editors // personal // nixos // containers // rust-tools // networking // utility // git // darwin;
  
  helpText = lib.concatStringsSep "\\n" (
    lib.mapAttrsToList (name: value: "  ${name} = ${value}") aliases
  );
in
{
  programs.bash.shellAliases = aliases // { aliases = "echo -e '${helpText}'"; };
  programs.zsh.shellAliases = aliases // { aliases = "echo -e '${helpText}'"; };
}
