{ pkgs, ... }: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
  };

  environment.systemPackages = with pkgs; [
    qemu_full
    skopeo
  ];
}
