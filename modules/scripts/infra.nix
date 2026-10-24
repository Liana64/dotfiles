# @desc: infra — home-infra Taskfile runner with bare-name task resolution
{...}: {
  flake.modules.homeManager.infra = {
    pkgs,
    nixpkgs-unstable,
    ...
  }: {
    home.packages = [
      (import ../_lib/shell-app.nix pkgs "infra" {
        runtimeInputs = import ../_lib/infra-tools.nix {
          inherit pkgs;
          unstable = nixpkgs-unstable;
        };
      })
    ];
  };
}
