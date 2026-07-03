# @desc: sops-nix secrets from the PQ-encrypted secretstore repo
{...}: {
  flake.modules.nixos.secrets = {
    inputs,
    lib,
    pkgs,
    ...
  }: let
    # sops may exec SOPS_AGE_KEY_CMD without a shell; the script owns the
    # $HOME expansion and the tty passphrase prompt
    editorKey = pkgs.writeShellScript "sops-editor-key" ''
      exec ${pkgs.age}/bin/age -d "$HOME/.config/sops/age/keys.txt.age"
    '';
    sopsWrapped = pkgs.symlinkJoin {
      name = "sops-wrapped";
      paths = [pkgs.sops pkgs.age];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/sops \
          --prefix PATH : ${lib.makeBinPath [pkgs.age]} \
          --set-default SOPS_AGE_KEY_CMD ${editorKey}
      '';
    };
  in {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops.defaultSopsFile = "${inputs.secrets}/secrets.yaml";
    # PQ host identity, minted by hand: the module's generateKey would be
    # classical X25519 and reintroduce harvest-now-decrypt-later
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    # no ssh-to-age fallbacks — host ssh keys are classical
    sops.age.sshKeyPaths = [];
    sops.gnupg.sshKeyPaths = [];

    # gate probes: default placement + the custom-path mechanism the real
    # migrations rely on
    sops.secrets.test = {};
    sops.secrets.test-path = {
      key = "test";
      path = "/var/secrets/test-path";
    };

    environment.systemPackages = [sopsWrapped];
  };
}
