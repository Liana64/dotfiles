# @desc: Resolves color palette from host theme into the colors arg
{osConfig, ...}: {
  # Palette follows the host's osConfig.theme; standalone home falls back to milberry.
  _module.args.colors =
    import ../../modules/common/colors/${osConfig.theme or "milberry"}.nix {};
}
