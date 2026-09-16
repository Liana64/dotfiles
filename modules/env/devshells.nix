_: {
  perSystem = {
    config,
    pkgs,
    inputs',
    ...
  }: {
    devShells.infra = pkgs.mkShell {
      packages = import ../_lib/infra-tools.nix {
        inherit pkgs;
        unstable = inputs'.nixpkgs-unstable.legacyPackages;
      };
      shellHook = config.pre-commit.installationScript;
    };
  };
}
