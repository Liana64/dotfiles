# @desc: Protonmail Bridge
{...}: {
  flake.modules.nixos.email = {
    services.protonmail-bridge.enable = true;
  };
}
