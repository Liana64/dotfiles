{ lib, pkgs, ... }: {
  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;
      #systemd-boot.memtest86.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Linux kernel: two options, with the second one being useful
    # when there are problems with the latest kernel and thus there
    # is a need to pin the installation to a specific version

    # Option (1): Latest kernel from the NixOS channel
    kernelPackages = pkgs.linuxPackages_latest;

    # Option (2): Pinned kernel version from the NixOS channel
    #kernelPackages = pkgs.linuxPackagesFor (pkgs.linuxKernel.kernels.linux_6_17);

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    # Kernel 7.0
    initrd.luks.cryptoModules = [
      "aes"
      # "aes_generic"
      "blowfish"
      "twofish"
      "serpent"
      "cbc"
      "xts"
      "lrw"
      "sha1"
      "sha256"
      "sha512"
      "af_alg"
      "algif_skcipher"
      "cryptd"
      "input_leds" # for capslock LED on most keyboards in case decryption requires password
    ];

    # TODO: Review kernel modules and disable unused
    #blacklistedKernelModules = [];
  };
}
