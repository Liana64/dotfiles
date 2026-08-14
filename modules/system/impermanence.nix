# @desc: impermanence option — declarative user password from sops on ephemeral-root hosts
{...}: {
  flake.modules.nixos.impermanence = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.impermanence = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Ephemeral root: shadow is rebuilt each boot, so the user password must come from the sops secretstore instead of host options";
    };

    config = lib.mkIf config.impermanence {
      users.mutableUsers = false;

      # secretstore holds the yescrypt hash base64-encoded
      sops.secrets.hashedPassword.neededForUsers = true;

      system.activationScripts = {
        decodeHashedPassword = {
          deps = ["setupSecretsForUsers"];
          text = ''
            umask 077
            mkdir -p /run/secrets-decoded
            ${pkgs.coreutils}/bin/base64 -d \
              ${config.sops.secrets.hashedPassword.path} \
              > /run/secrets-decoded/hashedPassword
          '';
        };
        users.deps = ["decodeHashedPassword"];
      };

      users.users.liana = {
        initialHashedPassword = lib.mkForce null;
        hashedPasswordFile = "/run/secrets-decoded/hashedPassword";
      };
    };
  };
}
