{ ... }: {
  services.mako = {
    enable = true;

    settings = {
      default-timeout = 3000;
      ignore-timeout = false;
      border-radius = 5;
      icons = true;
    };
  };
}
