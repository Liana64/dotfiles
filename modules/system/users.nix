# @desc: User account liana (groups, zsh)
{...}: {
  flake.modules.nixos.users = {
    config,
    lib,
    pkgs,
    ...
  }: {
    users.users.liana = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups =
        ["wheel" "audio" "video" "dialout"]
        ++ lib.optional config.networking.networkmanager.enable "networkmanager";
      openssh.authorizedKeys.keys = [];
    };

    programs.zsh.enable = true;
  };
}
