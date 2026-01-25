{ ... }:
{
  imports = [
    ./git.nix
    ./nvim.nix
    ./packages.nix
  ];

  programs.k9s = {
    enable = true;
    settings = import ./k9s/settings.nix;
    aliases = import ./k9s/aliases.nix;
    skins = import ./k9s/skins.nix;
    plugins = import ./k9s/plugins.nix;
  };

  #programs.direnv = {
  #  enable = true;
  #  enableZshIntegration = true;
  #  nix-direnv.enable = true;
  #};
}
