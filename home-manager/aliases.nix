{
  pkgs,
  lib,
  ...
}:
let
  editors = {
    vi = "nvim";
    vim = "nvim";
    n = "nvim";
  };

  personal = {
    l = "ls -laht";
    k = "kubectl";
  };

  containers = {
    sec-tools = "kubectl exec -it deploy/sec-tools -- zsh";
    blog = "kubectl rollout restart deployment blog -n default";
  };

  rust-tools = {
    cat = "bat";
    df = "duf";
    diff = "delta";
    du = "dust";
    find = "fd";
    grep = "rg";
    htop = "btop";
    neofetch = "fastfetch";
  };

  networking = {
    ifc = lib.mkForce "xh --body 'https://ifconfig.me'";
    ports = "ss -tunapl";
    fastping = "ping -c 100 -i 0.2";
    listening = "ss -tlnp";
    netstat = "ss";
  };

  utility = {
    bc = "bc -l";
    h = "history";
    j = "jobs -l";
    uuid = "uuidgen -x | tr '[:lower:]' '[:upper:]'";
    gpg-encrypt = "gpg -c --no-symkey-cache --cipher-algo=AES256";
    gpg-decrypt = "gpg -d";
  };

  git = {
    g = "git";
    gl = "git pull";
    gd = "git diff";
  };

  aliases = editors // personal // containers // rust-tools // networking // utility // git;
in
{
  programs.bash.shellAliases = aliases;
  programs.zsh.shellAliases = aliases;
}
