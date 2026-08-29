# @desc: GPG keys/config
{...}: {
  flake.modules.homeManager.gpg = {pkgs, ...}: let
    hardening = import ../_lib/systemd-hardening.nix;
  in {
    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };

    # pinentry children are Qt/GTK (@resources SIGSYS otherwise) and scdaemon
    # may drive the YubiKey over raw USB; card stubs need ~/.gnupg writable
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
      mutableKeys = false;
      mutableTrust = false;
      publicKeys = [
        {
          source = pkgs.writeText "pub.asc" (import ../_lib/keys.nix).lianaGpg;
          trust = "ultimate";
        }
      ];
    };

    systemd.user.tmpfiles.rules = ["d %h/.gnupg 0700 - - -"];
  };
}
