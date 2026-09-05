# Talos VM domain builder shared by the hypervisor hosts (m1/n1/n2/n3).
# Boot ISO matches talconfig's minimal schematic (qemu-guest-agent, secureboot);
# it only matters on fresh installs — installed nodes boot from disk (order 1).
{
  pkgs,
  lib,
}: let
  talosVersion = "v1.12.6";
  schematic = "d9cb0be10f95f364c88e92c9a695cc38373fb0f2f5ad8b612cba97d81c6b75be";

  ovmf =
    (pkgs.OVMF.override {
      secureBoot = true;
      tpmSupport = true;
    }).fd;

  mkHostdev = {
    bus,
    slot,
    fn,
  }: ''
    <hostdev mode="subsystem" type="pci" managed="yes">
      <source>
        <address domain="0x0000" bus="${bus}" slot="${slot}" function="${fn}"/>
      </source>
    </hostdev>
  '';

  mkDisk = {
    zvol,
    dev,
    boot ? null,
  }: ''
    <disk type="block" device="disk">
      <driver name="qemu" type="raw" cache="none" io="native" discard="unmap"/>
      <source dev="/dev/zvol/${zvol}"/>
      <target dev="${dev}" bus="scsi"/>
      ${lib.optionalString (boot != null) ''<boot order="${toString boot}"/>''}
    </disk>
  '';

  mkNic = {
    bridge,
    mac,
    vlan,
  }: ''
    <interface type="bridge">
      <source bridge="${bridge}"/>
      <mac address="${mac}"/>
      <vlan>
        <tag id="${toString vlan}"/>
      </vlan>
      <model type="virtio"/>
    </interface>
  '';
in {
  talosISO = pkgs.fetchurl {
    url = "https://factory.talos.dev/image/${schematic}/${talosVersion}/nocloud-amd64-secureboot.iso";
    hash = "sha256-KIFee+Fxt4I6ldrHDZRd2q9XCsehh3AON3msA1+M27E=";
  };

  mkTalosVM = {
    name,
    uuid,
    vcpus,
    memoryGiB,
    disks,
    nics,
    iso,
    hostdevs ? [],
  }: {
    active = true;
    restart = false;
    definition = pkgs.writeText "${name}.xml" ''
      <domain type="kvm">
        <name>${name}</name>
        <uuid>${uuid}</uuid>
        <memory unit="GiB">${toString memoryGiB}</memory>
        <vcpu placement="static">${toString vcpus}</vcpu>
        <iothreads>1</iothreads>
        <os>
          <type arch="x86_64" machine="q35">hvm</type>
          <loader readonly="yes" secure="yes" type="pflash">${ovmf}/FV/OVMF_CODE.fd</loader>
          <nvram template="${ovmf}/FV/OVMF_VARS.fd">/var/lib/libvirt/qemu/nvram/${name}.fd</nvram>
        </os>
        <features>
          <acpi/>
          <apic/>
          <smm state="on"/>
        </features>
        <cpu mode="host-passthrough"/>
        <clock offset="utc"/>
        <devices>
          <emulator>${pkgs.qemu_kvm}/bin/qemu-system-x86_64</emulator>
          <controller type="scsi" model="virtio-scsi">
            <driver iothread="1"/>
          </controller>
          ${lib.concatMapStrings mkDisk disks}
          <disk type="file" device="cdrom">
            <driver name="qemu" type="raw"/>
            <source file="${iso}"/>
            <target dev="sdz" bus="sata"/>
            <readonly/>
            <boot order="2"/>
          </disk>
          ${lib.concatMapStrings mkNic nics}
          <serial type="pty"/>
          <console type="pty"/>
          <channel type="unix">
            <target type="virtio" name="org.qemu.guest_agent.0"/>
          </channel>
          <tpm model="tpm-crb">
            <backend type="emulator" version="2.0"/>
          </tpm>
          <rng model="virtio">
            <backend model="random">/dev/urandom</backend>
          </rng>
          <graphics type="vnc" autoport="yes"/>
          <video>
            <model type="virtio"/>
          </video>
          <memballoon model="none"/>
          ${lib.concatMapStrings mkHostdev hostdevs}
        </devices>
      </domain>
    '';
  };
}
