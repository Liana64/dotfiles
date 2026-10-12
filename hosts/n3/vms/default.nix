{
  imports = [
    ./lab.nix
    ./talos.nix
  ];

  # 16G: 6 vm + 6 lab (3×2G) + ~1 qemu + 1 arc + ~1 host
  boot.kernelParams = ["zfs.zfs_arc_max=${toString (1024 * 1024 * 1024)}"];

  services.sanoid.datasets."rpool/var".useTemplate = ["daily"];
}
