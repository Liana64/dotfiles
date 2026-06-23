{
  config,
  lib,
  ...
}: {
  options.theme = lib.mkOption {
    type = lib.types.enum ["blueberry" "milberry"];
    default = "milberry";
    description = "Active color palette (modules/common/colors/<theme>.nix).";
  };

  # Resolve the palette and expose it as the `colors` module arg.
  config._module.args.colors = import ./colors/${config.theme}.nix {};
}
