# Talos ISO matches talconfig's minimal schematic (qemu-guest-agent, secureboot).
pkgs: let
  # https://factory.talos.dev/?target=cloud
  # TODO: Update image kernel params. This isn't a long-term fix, since all it
  # takes is one KVM escape CVE, but hey it's something:
  #
  # lockdown=integrity, required for tetragon eBPF
  # ia32_emulation=0 init_on_free=1 page_alloc.shuffle=1 debugfs=off
  # console=ttyS0 for virsh console
  # upgrade talosVersion then check /proc/config.gz for kernel defaults
  #
  talosVersion = "v1.12.6"; # TODO: Upgrade talosVersion *urgently*
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
    hash = "sha256-lYtYptbgCo+woEuQOH9SBMKvJOMV8wNRAMWOkhLCwpE=";
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
