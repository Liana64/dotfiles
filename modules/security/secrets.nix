# @desc: sops-nix secrets from the PQ-encrypted secretstore repo
{...}: {
  flake.modules.nixos.secrets = {
    inputs,
    pkgs,
    ...
  }: let
    # cache identity in the kernel user keyring; born in @s (possessed, so
    # setperm is allowed) then published to @u with uid-scope perms — session
    # keyrings differ per tab/launcher lineage, @u reaches them all
    editorKey = pkgs.writeShellScript "sops-editor-key" ''
      keyctl=${pkgs.keyutils}/bin/keyctl
      "$keyctl" pipe %user:sops-editor 2>/dev/null && exit
      id=$(${pkgs.age}/bin/age -d "$HOME/.config/sops/age/nix.age") || exit 1
      kid=$(printf %s "$id" | "$keyctl" padd user sops-editor @s)
      "$keyctl" setperm "$kid" 0x3f3f0000
      "$keyctl" link "$kid" @u && "$keyctl" unlink "$kid" @s
      "$keyctl" timeout "$kid" 300
      printf %s "$id"
    '';
    sopsStore = pkgs.runCommand "sops-store" {buildInputs = [pkgs.makeWrapper];} ''
      mkdir -p $out/bin
      makeWrapper ${pkgs.sops}/bin/sops $out/bin/sops-store \
        --set-default SOPS_AGE_KEY_CMD ${editorKey}
    '';
  in {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops.defaultSopsFile = "${inputs.secrets}/secrets.yaml";
    # PQ host identity, minted by hand: the module's generateKey would be
    # classical X25519 and reintroduce harvest-now-decrypt-later
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    # no ssh-to-age fallbacks — host ssh keys are classical
    sops.age.sshKeyPaths = [];
    sops.gnupg.sshKeyPaths = [];

    # canary: cheap decrypt-chain check at every activation
    sops.secrets.test = {};

    sops.secrets."wireguard/wg0.conf" = {
      path = "/var/secrets/wireguard/wg0.conf";
      mode = "0400";
    };
    sops.secrets."wireguard/trusted-networks" = {
      path = "/var/secrets/wireguard/trusted-networks";
      mode = "0400";
    };
    sops.secrets."eek/gateway-key" = {
      path = "/var/secrets/eek/gateway-key";
      owner = "liana";
      mode = "0400";
    };
    sops.secrets."syncthing/gui-passwd" = {
      path = "/var/secrets/syncthing/gui-passwd";
      owner = "liana";
      mode = "0400";
    };

    environment.systemPackages = [sopsStore];
  };
}
