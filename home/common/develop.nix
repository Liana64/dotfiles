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
