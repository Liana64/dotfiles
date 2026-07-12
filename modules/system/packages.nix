# @desc: System packages and base env vars (EDITOR, BROWSER)
{...}: {
  flake.modules.nixos.packages = {pkgs, ...}: {
    environment.variables = {
      EDITOR = "vim";
      BROWSER = "firefox";
    };

    environment.systemPackages = with pkgs; [
      # android-tools (nix shell on demand)
      backblaze-b2
      gptfdisk
      lsof
      nh
      seahorse
      traceroute
      unzip
      vim
      wget
      # wireshark (nix shell on demand, dissectors parse hostile input)
    ];
  };
}
