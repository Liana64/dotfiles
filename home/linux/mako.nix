{ ... }: {
  services.mako = {
    enable = true;

    settings = {
      default-timeout = 3000;
      ignore-timeout = false;
      background-color = "#222222";
      border-color = "#282828";
      border-radius = 5;
      font = "JetBrainsMono Nerd Font 10";
      icons = false;
    };
  };
}
