# Talos ISO matches talconfig's minimal schematic (qemu-guest-agent, secureboot).
pkgs: let
  # https://factory.talos.dev/?target=cloud
  talosVersion = "v1.12.6";
  schematic = "d9cb0be10f95f364c88e92c9a695cc38373fb0f2f5ad8b612cba97d81c6b75be";

  # https://access.redhat.com/downloads/content/rhel
  rhel = version: sha256:
    pkgs.requireFile {
      name = "rhel-${version}-x86_64-kvm.qcow2";
      url = "https://access.redhat.com/downloads/content/rhel";
      inherit sha256;
    };
in {
  talos = pkgs.fetchurl {
    url = "https://factory.talos.dev/image/${schematic}/${talosVersion}/nocloud-amd64-secureboot.iso";
    hash = "sha256-+4/wu0bbTuSCPVfpT3OtBv7nVXkSU/pefkYQ6efELVk=";
  };

  rhel8 = rhel "8.10" "820853871801754056642ead33834fbe5640421b57e07f2c084684f4d1a7d2fe";
  rhel9 = rhel "9.8" "b99091f1b4489111004d449398d9cc6aa024cb48b02c72fa99e6ca1fc48a7e4e";
  rhel10 = rhel "10.2" "caaacd0b11bbc4206f8c7fec8594b82b4366b3f88ff974dbbf373832ae676f4f";
}
