{ ... }: {
  services.mako = {
    enable = true;
    defaultTimeout = 3000;
    ignoreTimeout = false;
    
    extraConfig = ''
      [urgency=low]
      default-timeout=3000
      
      [urgency=critical]
      default-timeout=0
    '';
  };
}
