{lib, ...}: {
  imports = [
    ./opnsense.nix
    ./talos.nix
  ];

  # 32G: 24 vm + 3 opnsense standby + ~1 qemu + 2 arc + ~2 host
  boot.kernelParams = ["zfs.zfs_arc_max=${toString (2 * 1024 * 1024 * 1024)}"];

  services.sanoid.datasets = lib.genAttrs ["rpool/var" "rpool/vms/talos-os"] (_: {useTemplate = ["daily"];});
}
