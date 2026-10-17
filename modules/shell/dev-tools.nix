# @desc: Dev CLI packages and lazygit
_: {
  flake.modules.homeManager.devPackages = {
    pkgs,
    config,
    lib,
    ...
  }: {
    home.packages = with pkgs; [
      age
      distrobox
      go-task
      jq
      kubectl
      nix-tree
      pre-commit
      sops
      yq-go
    ];

    programs.lazygit = {
      enable = true;
      enableZshIntegration = false;
      settings.git.autoFetch = false;
      settings.gui.theme.selectedLineBgColor = lib.mkIf (config.lib ? stylix) (lib.mkForce [config.lib.stylix.colors.withHashtag.base02]);
    };
  };
}
