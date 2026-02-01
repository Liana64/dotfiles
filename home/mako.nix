{ ... }: {
  services.mako = {
    enable = true;

    settings = {
      defaultTimeout = 3000;
      ignoreTimeout = false;
      backgroundColor = "#1e1e2e";
      textColor = "#cdd6f4";
      borderColor = "#89b4fa";
      borderRadius = 5;
      borderSize = 2;
    };

    extraConfig = ''
      [urgency=low]
      default-timeout=3000
      
      [urgency=critical]
      default-timeout=0
    '';
  };
}
