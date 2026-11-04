# @desc: ssh client config, hardened sshd baseline
{...}: {
  flake.modules.homeManager.ssh = {...}: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        IdentityFile = ["~/.ssh/id_yk1" "~/.ssh/id_yk2" "~/.ssh/id_yk3"];
        IdentitiesOnly = true;
      };
    };
  };

  flake.modules.nixos.sshd = {lib, ...}: {
    services.openssh = {
      openFirewall = false;
      hostKeys = lib.mkDefault [
        {
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
        }
      ];
      settings = {
        AuthenticationMethods = "publickey";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        PubkeyAcceptedAlgorithms = "sk-ssh-ed25519@openssh.com,ssh-ed25519";
        PubkeyAuthOptions = "verify-required";
        HostKeyAlgorithms = "ssh-ed25519";
        KexAlgorithms = ["mlkem768x25519-sha256" "sntrup761x25519-sha512"];
        Ciphers = ["chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com"];
        Macs = ["hmac-sha2-512-etm@openssh.com" "hmac-sha2-256-etm@openssh.com"];
      };
    };
  };
}
