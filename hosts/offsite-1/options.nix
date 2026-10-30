{
  config,
  inputs,
  ...
}: let
  addr = inputs.self.network.offsite.hosts.${config.networking.hostName};
in {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    ./disko.nix
    ./forgejo.nix
    ./network.nix
    ./ntfy.nix
    ./tripwire.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  impermanence = true;
  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
  users.users.root.hashedPassword = "!";

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = false;
    };
    initrd = {
      systemd.enable = true;
      availableKernelModules = ["virtio_scsi" "sd_mod"];
    };
    tmp.useTmpfs = true;

    kernelParams = [
      "slab_nomerge"
      "init_on_alloc=1"
      "init_on_free=1"
      "page_alloc.shuffle=1"
      "oops=panic"
      "panic=10"
    ];

    kernel.sysctl = {
      "kernel.unprivileged_bpf_disabled" = 1;
      "net.core.bpf_jit_harden" = 2;
      "kernel.io_uring_disabled" = 2;
      "kernel.perf_event_paranoid" = 3;
      "dev.tty.ldisc_autoload" = 0;
      "vm.unprivileged_userfaultfd" = 0;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.log_martians" = true;
      "net.ipv4.conf.default.log_martians" = true;
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.ipv6.conf.default.disable_ipv6" = 1;
    };
  };

  security.lockKernelModules = true;

  systemd.coredump.enable = false;
  services.dbus.implementation = "broker";
  zramSwap.enable = true;

  motd.description = "offsite forge";

  networking = {
    hostName = "offsite-1";
    hostId = "5b64aa5d";
  };

  environment.etc.machine-id.text = "acc955c171239aaa6e0a66b8c973a24b\n";

  fileSystems = {
    "/persist".neededForBoot = true;
    "/var/log".neededForBoot = true;
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/lib/chrony"
      "/var/lib/acme"
      {
        directory = "/var/lib/forgejo";
        user = "forgejo";
        group = "forgejo";
        mode = "0750";
      }
    ];
  };

  services.openssh = {
    enable = true;
    openFirewall = false;
    startWhenNeeded = false;
    listenAddresses = [{inherit addr;}];
    hostKeys = [
      {
        type = "ed25519";
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
      }
    ];
    settings = {
      AllowUsers = ["liana"];
      AuthenticationMethods = "publickey";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAcceptedAlgorithms = "sk-ssh-ed25519@openssh.com";
      PubkeyAuthOptions = "verify-required";
      KexAlgorithms = ["mlkem768x25519-sha256" "sntrup761x25519-sha512"];
      Ciphers = ["chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com"];
      X11Forwarding = false;
      AllowAgentForwarding = false;
      AllowTcpForwarding = false;
      AllowStreamLocalForwarding = false;
      PermitTunnel = false;
      MaxAuthTries = 2;
      LoginGraceTime = 20;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
    };
  };

  systemd.services.sshd = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };

  users.users.liana = {
    uid = 1000;
    openssh.authorizedKeys.keys = inputs.self.keys.liana;
  };

  nix.settings.max-jobs = 0;

  system.stateVersion = "26.05";
}
