# @desc: GPG keys/config
{...}: {
  flake.modules.homeManager.gpg = {
    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };

    programs.gpg = {
      enable = true;
      scdaemonSettings.disable-ccid = true;
    };
  };
}
