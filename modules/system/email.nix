# @desc: Protonmail Bridge
{...}: {
  flake.modules.nixos.email = {hardening, ...}: {
    services.protonmail-bridge.enable = true;

    # bridge state spans three protonmail dirs; the rest of home stays read-only
    systemd.user.services.protonmail-bridge.serviceConfig =
      hardening.confined
      // {
        ProtectHome = "read-only";
        ReadWritePaths = [
          "%h/.config/protonmail"
          "%h/.cache/protonmail"
          "%h/.local/share/protonmail"
        ];
      };
  };
}
