# @desc: GPG keys/config
{...}: {
  flake.modules.homeManager.gpg = {pkgs, ...}: let
    hardening = import ../_lib/systemd-hardening.nix;
    fpr = "C4E1D3BB2F69070998CE1981DC03DFEB7A0A710D";
    importKey = pkgs.writeShellScript "gpg-import-key" ''
      gpg=${pkgs.gnupg}/bin/gpg
      "$gpg" --list-secret-keys ${fpr} >/dev/null 2>&1 && exit
      "$gpg" --batch --import /var/secrets/gpg/secret-key
      printf '%s:6:\n' ${fpr} | "$gpg" --import-ownertrust
    '';
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

    systemd.user.tmpfiles.rules = ["d %h/.gnupg 0700 - - -"];

    systemd.user.services.gpg-import = {
      Unit.Description = "Import sops-provisioned GPG secret key";
      Service = {
        Type = "oneshot";
        ExecStart = "${importKey}";
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
