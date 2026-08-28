# @desc: installer ISO config — ssh-only provisioning media (nix-build-installer)
{inputs, ...}: {
  flake.nixosConfigurations.installer = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      {
        nixpkgs.hostPlatform = "x86_64-linux";
        boot.zfs.forceImportRoot = false;
        zramSwap = {
          enable = true;
          memoryPercent = 100;
        };
        services.openssh.settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
        users.users.root.openssh.authorizedKeys.keys = [
          (import ../_lib/keys.nix).liana
        ];
      }
    ];
  };
}
