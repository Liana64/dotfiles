# @desc: Rust language — nixpkgs toolchain + rust-analyzer on helix's PATH
{...}: {
  perSystem = {pkgs, ...}: {
    devShells.rust = pkgs.mkShell {
      packages = with pkgs; [
        cargo
        rustc
        clippy
        rustfmt
        rust-analyzer
      ];
    };
  };

  flake.modules.homeManager.helix = {pkgs, ...}: {
    programs.helix.extraPackages = with pkgs; [
      cargo
      rustc
      rust-analyzer
    ];
  };
}
