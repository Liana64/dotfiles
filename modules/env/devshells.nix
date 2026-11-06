# @desc: Infra devshell
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
      shellHook = ''
        if [ -e "$(git rev-parse --show-toplevel 2>/dev/null)/scripts/check-k8s-secrets-encrypted.sh" ]; then
          ${config.pre-commit.installationScript}
        fi
      '';
    };
  };
}
