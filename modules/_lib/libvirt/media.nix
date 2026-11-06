pkgs: let
  # NOTE: ia32_emulation=0 will stop 32-bit binaries from running in containers
  # NOTE: This image is ready for Piraeus for when we upgrade (drbd, qemu-guest-agent, sd-boot, secureboot).
  # https://factory.talos.dev/?target=cloud
  talosVersion = "v1.14.5";
  schematic = "79d245f689b37bd21ff1514408f1bb4cd448b21400377bf2510603df2217c0c3";

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
    hash = "sha256-0jEsdiZN3QVp5ylI8Dcsf/USswkB8y8RdRjyj1sJWSc=";
  };

  opnsense = pkgs.runCommand "OPNsense-26.7-dvd-amd64.iso" {
    src = pkgs.fetchurl {
      url = "https://pkg.opnsense.org/releases/26.7/OPNsense-26.7-dvd-amd64.iso.bz2";
      hash = "sha256-lcr+3abVsizoMuJJ3CMJEQ++4Z+BOteM8ouz04cYa/s="; # sha256: 95cafedda6d5b22ce832e249dc2309110fbee19f813ad78cf28bb3d387186bfb
    };
    nativeBuildInputs = [pkgs.bzip2];
  } "bunzip2 -c $src > $out";

  rhel8 = rhel "8.10" "820853871801754056642ead33834fbe5640421b57e07f2c084684f4d1a7d2fe";
  rhel9 = rhel "9.8" "b99091f1b4489111004d449398d9cc6aa024cb48b02c72fa99e6ca1fc48a7e4e";
  rhel10 = rhel "10.2" "caaacd0b11bbc4206f8c7fec8594b82b4366b3f88ff974dbbf373832ae676f4f";
}
