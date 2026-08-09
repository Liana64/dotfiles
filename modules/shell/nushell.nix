# @desc: Nushell — structured-pipeline sidecar (nu -c one-shots)
{...}: {
  flake.modules.homeManager.nushell = {...}: {
    programs.nushell = {
      enable = true;
      settings.show_banner = false;
      extraConfig = ''
        if ("/run/audit-wall" | path exists) and (open --raw /run/audit-wall | is-not-empty) {
          print (open --raw /run/audit-wall)
          print ""
        }
        if (random bool) { fortune } else { dice }
      '';
    };
  };
}
