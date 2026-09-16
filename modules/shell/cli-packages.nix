{...}: {
  flake.modules.homeManager.cliPackages = {pkgs, ...}: {
    home.packages = with pkgs; [
      asciinema
      bat
      btop
      difftastic
      duf
      dust
      eza
      fastfetch
      fd
      ffmpeg
      fortune
      fzf
      imagemagick
      just
      numbat
      ripgrep
      ripgrep-all
      yazi
    ];
  };
}
