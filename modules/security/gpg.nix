# @desc: GPG keys/config
{...}: {
  flake.modules.homeManager.gpg = let
    hardening = import ../_lib/systemd-hardening.nix;
  in {
    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };

    # pinentry children are Qt/GTK (@resources SIGSYS otherwise) and scdaemon
    # may drive the YubiKey over raw USB; keys need ~/.gnupg writable
    systemd.user.services.gpg-agent.Service =
      hardening.confined
      // {
        SystemCallFilter = ["@system-service" "~@privileged"];
        PrivateDevices = false;
        ProtectHome = "read-only";
        ReadWritePaths = "%t %h/.gnupg";
      };

    programs.gpg = {
      enable = true;
      scdaemonSettings.disable-ccid = true;
    };
  };
}
