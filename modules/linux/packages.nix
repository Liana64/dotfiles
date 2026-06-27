# @desc: System packages and base env vars (EDITOR, BROWSER)
{ pkgs, ... }: {
  environment.variables = {
    EDITOR = "vim";
    BROWSER = "firefox";
  };

  environment.systemPackages = with pkgs; [
    android-tools
    backblaze-b2
    gptfdisk
    just
    lsof
    nh
    seahorse
    traceroute
    unzip
    vim
    wget
    wireshark
  ];
}
