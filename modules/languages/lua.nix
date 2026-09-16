# @desc: Lua language — lua-ls, telemetry off
{...}: {
  flake.modules.homeManager.helix = {pkgs, ...}: {
    programs.helix = {
      extraPackages = [pkgs.lua-language-server];
      languages.language-server.lua-language-server.config.Lua.telemetry.enable = false;
    };
  };
}
