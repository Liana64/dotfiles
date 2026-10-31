# @desc: installer ISO config — ssh-only provisioning media (nix-build-installer)
{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.installer = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs;};
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      config.flake.modules.nixos.hardwareTools
      config.flake.modules.nixos.nixCache
      {
        nixpkgs.hostPlatform = "x86_64-linux";
        boot.zfs.forceImportRoot = false;
        networking = {
          hostName = "nixos-installer";
          networkmanager.enable = inputs.nixpkgs.lib.mkForce false;
          useNetworkd = true;
          useDHCP = false;
          firewall.allowedUDPPorts = [5353];
        };
        services.resolved = {
          enable = true;
          settings.Resolve.MulticastDNS = true;
        };
        systemd.network.networks."10-ether" = {
          matchConfig.Type = "ether";
          networkConfig = {
            DHCP = "yes";
            LinkLocalAddressing = "yes";
            MulticastDNS = true;
          };
          linkConfig.RequiredForOnline = "no";
        };
        zramSwap = {
          enable = true;
          memoryPercent = 100;
        };
        services.openssh.settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
        users.users.root.openssh.authorizedKeys.keys =
          config.flake.keys.liana;
      }
    ];
  };
}
