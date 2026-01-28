{ pkgs, ... }: {
  # Use systemd-boot
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Linux kernel: two options, with the second one being useful
    # when there are problems with the latest kernel and thus there
    # is a need to pin the installation to a specific version

    # Option (1): Latest kernel from the NixOS channel
    kernelPackages = pkgs.linuxPackages_latest;

    # Option (2): Pinned kernel version from the NixOS channel
    #kernelPackages = pkgs.linuxPackagesFor (pkgs.linuxKernel.kernels.linux_6_17);

    # TODO: Review kernel modules and disable unused
    #blacklistedKernelModules = [];
  };
}
