# @desc: k9s Kubernetes TUI
{ pkgs, config, lib, ... }: let
  inherit (config.lib.stylix.colors.withHashtag) base04 base07 base0D;
in {
  programs.k9s = {
    enable = true;
    settings = import ./k9s/settings.nix;
    aliases = import ./k9s/aliases.nix;
    # TODO: Fix broken k9s plugins
    #plugins = import ./k9s/plugins.nix;

    # Stylix' k9s skin leaves the selected row near-invisible; add a filled bar.
    skins.stylix.k9s.views.table = {
      cursorFgColor = base07;
      cursorBgColor = base0D;
    };
    # Stylix sets the prompt suggestion to base03 (comment); unreadable on dark bg.
    skins.stylix.k9s.prompt.suggestColor = lib.mkForce base04;
  };
  xdg.configFile."k9s/plugins.yaml".source =
    (pkgs.formats.yaml {}).generate "plugins.yaml" (import ./k9s/plugins.nix);
}
