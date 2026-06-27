# @desc: Theme option + colors arg, across nixos + home
{...}: {
  flake.modules.nixos.theme = {
    config,
    lib,
    ...
  }: {
    options.theme = lib.mkOption {
      type = lib.types.enum ["blueberry" "milberry"];
      default = "milberry";
      description = "Active color palette (modules/_lib/colors/<theme>.nix).";
    };

    # Resolve the palette and expose it as the `colors` module arg.
    config._module.args.colors = import ../_lib/colors/${config.theme}.nix {};
  };

  # Home palette follows the host's osConfig.theme; standalone home falls back to milberry.
  flake.modules.homeManager.theme = {osConfig, ...}: {
    _module.args.colors = import ../_lib/colors/${osConfig.theme or "milberry"}.nix {};
  };
}
