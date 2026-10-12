# Talos ISO matches talconfig's minimal schematic (qemu-guest-agent, secureboot).
pkgs: let
  talosVersion = "v1.12.6";
  schematic = "d9cb0be10f95f364c88e92c9a695cc38373fb0f2f5ad8b612cba97d81c6b75be";

  rhel = version: sha256:
    pkgs.requireFile {
      name = "rhel-${version}-x86_64-dvd.iso";
      url = "https://access.redhat.com/downloads/content/rhel";
      inherit sha256;
    };
in {
  talos = pkgs.fetchurl {
    url = "https://factory.talos.dev/image/${schematic}/${talosVersion}/nocloud-amd64-secureboot.iso";
    hash = "sha256-+4/wu0bbTuSCPVfpT3OtBv7nVXkSU/pefkYQ6efELVk=";
  };

  rhel8 = rhel "8.10" pkgs.lib.fakeSha256;
  rhel9 = rhel "9.8" pkgs.lib.fakeSha256;
  rhel10 = rhel "10.2" pkgs.lib.fakeSha256;
}
