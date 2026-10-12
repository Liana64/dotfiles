{lib, ...}: {
  imports = [
    ./opnsense.nix
    ./talos.nix
  ];

  # 32G: 24 vm + 4 opnsense + ~1 qemu + 1.5 arc + ~1.5 host
  boot.kernelParams = ["zfs.zfs_arc_max=${toString (1536 * 1024 * 1024)}"];

  # talos-pool unsnapshotted: ~35G pool slack cannot absorb qbt churn deltas
  services.sanoid.datasets = lib.genAttrs ["rpool/var" "rpool/vms/talos-os"] (_: {useTemplate = ["daily"];});
}
