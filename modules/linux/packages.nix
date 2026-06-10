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
