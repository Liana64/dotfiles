{...}: {
  flake.modules.homeManager.devPackages = {pkgs, ...}: {
    home.packages = with pkgs; [
      age
      distrobox
      go-task
      jq
      kubectl
      lazygit
      nix-tree
      pre-commit
      sops
      yq-go
    ];
  };
}
