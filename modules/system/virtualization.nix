# @desc: Podman + qemu/skopeo
{...}: {
  flake.modules.nixos.virtualization = {pkgs, ...}: {
    virtualisation.podman = {
      enable = true;
      dockerCompat = false;
    };

    environment.systemPackages = with pkgs; [
      qemu_full
      skopeo
    ];
  };
}
