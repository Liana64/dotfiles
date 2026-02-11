{ lib, ... }: {
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      sync_address = "https://sh.labs.lianas.org";
      auto_sync = true;
      sync_frequency = "5m";
      style = "compact";
      inline_height = 20;
      show_preview = true;
      filter_mode_shell_up_key_binding = "directory";
    };
  };

  xdg.configFile."atuin/config.toml".force = lib.mkForce true;
}
