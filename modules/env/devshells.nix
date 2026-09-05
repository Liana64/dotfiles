# @desc: Dev shells (nix develop .#infra|rust) — project toolchains kept off the global profile
_: {
  perSystem = {
    config,
    pkgs,
    inputs',
    ...
  }: {
    devShells = {
      infra = pkgs.mkShell {
        packages = import ../_lib/infra-tools.nix {
          inherit pkgs;
          unstable = inputs'.nixpkgs-unstable.legacyPackages;
        };
        shellHook = config.pre-commit.installationScript;
      };

      rust = pkgs.mkShell {
        packages = with pkgs; [
          cargo
          rustc
          clippy
          rustfmt
          rust-analyzer
        ];
      };
    };
  };
}
