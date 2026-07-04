# @desc: System packages and base env vars (EDITOR, BROWSER)
{...}: {
  flake.modules.nixos.packages = {pkgs, ...}: {
    environment.variables = {
      EDITOR = "vim";
      BROWSER = "firefox";
    };

    environment.systemPackages = with pkgs; [
      android-tools
      backblaze-b2
      gptfdisk
      lsof
      nh
      seahorse
      traceroute
      unzip
      vim
      wget
      wireshark
    ];
  };
}
