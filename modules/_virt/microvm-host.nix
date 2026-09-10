# @desc: microvm.nix host runner — jailer-grade systemd confinement on microvm@
{inputs, ...}: let
  hardening = import ../_lib/systemd-hardening.nix;
in {
  flake.modules.nixos.microvm-host = {
    imports = [inputs.microvm.nixosModules.host];

    systemd.services."microvm@".serviceConfig =
      hardening.confined
      // {
        CapabilityBoundingSet = "";
        PrivateDevices = false;
        DevicePolicy = "closed";
        DeviceAllow = ["/dev/kvm rw" "/dev/net/tun rw" "/dev/vhost-net rw" "/dev/vhost-vsock rw"];
        ProtectSystem = "strict";
        ReadWritePaths = ["/var/lib/microvms"];
        MemoryDenyWriteExecute = false;
        RestrictAddressFamilies = ["AF_UNIX" "AF_VSOCK"];
        IPAddressDeny = "any";
        SystemCallFilter = ["@system-service" "~@privileged" "~bpf"];
      };
  };
}
