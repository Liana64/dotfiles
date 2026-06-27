# @desc: Rust toolchain (cargo, rustc, clippy, rust-analyzer)
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cargo
    rustc
    clippy
    rustfmt
    rust-analyzer
  ];
}
