 { pkgs, nixpkgs-unstable, ... }:
 {
  home.packages = with pkgs; [
    autotiling-rs
    bc
    cosign
    cider-2
    moreutils
    pavucontrol
    pciutils
    protonmail-bridge
    #winbox4
    #todoist-electron
  #] ++ (with nixpkgs-unstable; [
  #  claude-code
  ];
 }
