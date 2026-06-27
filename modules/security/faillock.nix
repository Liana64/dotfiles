# @desc: PAM faillock lockout for swaylock
{...}: {
  flake.modules.nixos.faillock = {
    config,
    pkgs,
    lib,
    ...
  }: let
    services = ["swaylock"];
    pamFaillock = "${pkgs.pam}/lib/security/pam_faillock.so";
    mkFaillock = svc: let
      cur = config.security.pam.services.${svc}.rules;
    in {
      rules.auth.faillockPreauth = {
        order = cur.auth.unix.order - 50;
        control = "required";
        modulePath = pamFaillock;
        settings.preauth = true;
      };
      rules.auth.faillockAuthfail = {
        order = cur.auth.unix.order + 50;
        control = "[default=die]";
        modulePath = pamFaillock;
        settings.authfail = true;
      };
      rules.account.faillock = {
        order = cur.account.unix.order - 50;
        control = "required";
        modulePath = pamFaillock;
      };
    };
  in {
    security.pam.services = lib.genAttrs services mkFaillock;

    systemd.tmpfiles.rules = ["d /run/faillock 0700 liana users -"];

    environment.etc."security/faillock.conf".text = ''
      deny = 5
      fail_interval = 900
      unlock_time = 600
      audit
    '';

    environment.systemPackages = [
      (pkgs.runCommand "faillock" {} "mkdir -p $out/bin; ln -s ${pkgs.pam}/bin/faillock $out/bin/faillock")
    ];
  };
}
