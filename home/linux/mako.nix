{ ... }: {
  services.mako = {
    enable = true;

    settings = {
      default-timeout = 4000;
      ignore-timeout = false;
      border-radius = 5;
      icons = true;
    };
  };
}
