{ pkgs, ... }: {
  # TODO: Fix broken k9s plugins
  programs.k9s = {
    enable = true;
    settings = import ./k9s/settings.nix;
    aliases = import ./k9s/aliases.nix;
    skins = import ./k9s/skins.nix;
    #plugins = import ./k9s/plugins.nix;
  };
  xdg.configFile."k9s/plugins.yaml".source =
    (pkgs.formats.yaml {}).generate "plugins.yaml" (import ./k9s/plugins.nix);
}
