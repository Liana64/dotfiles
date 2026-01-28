{config, pkgs, ...}:
{
  # TODO: Make sure `wireguard-tools` is included
  # NOTE Maybe install `wireguard-ui` while getting this set up

  # TODO: Add files
  networking.wg-quick.interfaces.wg0 = {
    privateKeyFile = "/var/secrets/wireguard/0/wg.key";
    address = [ "172.17.0.90/32" ];
    dns = [ "172.17.0.1" ];
    autostart = false;
    peers = [
      {
        publicKey = "";
        presharedKeyFile = "/var/secrets/wireguard/0/psk.key";
        allowedIPs = [ "0.0.0.0/0" "::/0" ];

        # TODO: Encrypt this with sops/age
        endpoint = "";
      }
    ];
  };
}
