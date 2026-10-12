{
  inputs,
  pkgs,
  lib,
}: let
  ovmf =
    (pkgs.OVMF.override {
      secureBoot = true;
      tpmSupport = true;
    }).fd;

  mkDisk = {
    zvol,
    dev,
    bus ? "scsi",
    boot ? null,
  }: {
    type = "block";
    device = "disk";
    driver = {
      name = "qemu";
      type = "raw";
      cache = "none";
      io = "native";
      discard = "unmap";
    };
    source.dev = "/dev/zvol/${zvol}";
    target = {inherit dev bus;};
    boot = lib.mapNullable (order: {inherit order;}) boot;
    serial =
      if bus == "nvme"
      then baseNameOf zvol
      else null;
  };

  mkCdrom = iso: {
    type = "file";
    device = "cdrom";
    driver = {
      name = "qemu";
      type = "raw";
    };
    source.file = "${iso}";
    target = {
      dev = "sdz";
      bus = "sata";
    };
    readonly = {};
    boot.order = 2;
  };

  mkNic = {
    bridge,
    mac,
    vlan,
  }: {
    type = "bridge";
    source = {inherit bridge;};
    mac.address = mac;
    vlan.tag.id = vlan;
    model.type = "virtio";
  };
in {
  iso = import ./media.nix pkgs;

  mkVM = {
    name,
    uuid,
    vcpus,
    memoryGiB,
    disks,
    nics,
    iso ? null,
    devices ? {},
    active ? true,
  }: {
    inherit active;
    restart = false;
    definition = inputs.nixvirt.lib.domain.writeXML {
      type = "kvm";
      inherit name uuid;
      memory = {
        count = memoryGiB;
        unit = "GiB";
      };
      vcpu = {
        placement = "static";
        count = vcpus;
      };
      iothreads.count = 1;
      os = {
        type = "hvm";
        arch = "x86_64";
        machine = "q35";
        loader = {
          readonly = true;
          secure = true;
          type = "pflash";
          path = "${ovmf}/FV/OVMF_CODE.fd";
        };
        nvram = {
          template = "${ovmf}/FV/OVMF_VARS.fd";
          path = "/var/lib/libvirt/qemu/nvram/${name}.fd";
        };
      };
      features = {
        acpi = {};
        apic = {};
        smm.state = true;
      };
      cpu.mode = "host-passthrough";
      clock.offset = "utc";
      devices =
        {
          emulator = "${pkgs.qemu_kvm}/bin/qemu-system-x86_64";
          controller = {
            type = "scsi";
            model = "virtio-scsi";
            driver.iothread = 1;
          };
          disk = map mkDisk disks ++ lib.optional (iso != null) (mkCdrom iso);
          interface = map mkNic nics;
          serial.type = "pty";
          console.type = "pty";
          channel = {
            type = "unix";
            target = {
              type = "virtio";
              name = "org.qemu.guest_agent.0";
            };
          };
          tpm = {
            model = "tpm-crb";
            backend = {
              type = "emulator";
              version = "2.0";
            };
          };
          rng = {
            model = "virtio";
            backend = {
              model = "random";
              source = "/dev/urandom";
            };
          };
          graphics = {
            type = "vnc";
            autoport = true;
          };
          video.model.type = "virtio";
          memballoon.model = "none";
        }
        // devices;
    };
  };
}
