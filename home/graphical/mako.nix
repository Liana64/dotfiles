{ ... }: {
  services.mako = {
    enable = true;

    settings = {
      defaultTimeout = 2000;
      ignoreTimeout = false;
      backgroundColor = "#1e1e2e";
      textColor = "#cdd6f4";
      borderColor = "#89b4fa";
      borderRadius = 5;
      borderSize = 2;
    };
  };
}
