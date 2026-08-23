# @desc: installer ISO config — ssh-only provisioning media (nix-build-installer)
{inputs, ...}: {
  flake.nixosConfigurations.installer = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      {
        nixpkgs.hostPlatform = "x86_64-linux";
        boot.zfs.forceImportRoot = false;
        services.openssh.settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILeTWOmGCJ4CGx9RQPoCwXb81sZbN3gbk9iaGliu47aM liana@fw-2026"
        ];
      }
    ];
  };
}
