 { pkgs, ... }:
 {
  home.packages = with pkgs; [
    autotiling-rs
    bc
    #claude-code
    cosign
    cider-2
    moreutils
    pavucontrol
    pciutils
    protonmail-bridge
    #todoist-electron
  ];
 }
