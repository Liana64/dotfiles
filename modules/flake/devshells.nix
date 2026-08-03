# @desc: Dev shells (nix develop .#infra|rust) — project toolchains kept off the global profile
{...}: {
  perSystem = {
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
