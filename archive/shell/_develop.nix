# @desc: Rust toolchain (cargo, rustc, clippy, rust-analyzer)
{...}: {
  flake.modules.homeManager.develop = {pkgs, ...}: {
    home.packages = with pkgs; [
      cargo
      rustc
      clippy
      rustfmt
      rust-analyzer
    ];
  };
}
