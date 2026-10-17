_: {
  flake.modules.homeManager.devPackages = {pkgs, ...}: {
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
    };
  };
}
