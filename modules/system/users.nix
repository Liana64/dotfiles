# @desc: User account liana (groups, zsh)
{...}: {
  flake.modules.nixos.users = {pkgs, ...}: {
    users.users.liana = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = ["wheel" "networkmanager" "audio" "video" "dialout"];
      openssh.authorizedKeys.keys = [];
    };

    programs.zsh.enable = true;
  };
}
