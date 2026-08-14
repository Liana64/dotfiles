# @desc: nushell option — Nushell as the interactive shell in place of zsh
{...}: {
  flake.modules.nixos.nushell = {lib, ...}: {
    options.nushell = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Interactive shell: Nushell instead of zsh. Terminals launch it; zsh stays the login shell.";
    };
  };

  flake.modules.homeManager.nushell = {
    lib,
    osConfig,
    ...
  }: {
    programs.nushell = lib.mkIf (osConfig.nushell or false) {
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
