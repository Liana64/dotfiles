# @desc: User account liana (groups, zsh)
{ pkgs, ... }: {
  users.users.liana = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "dialout" ];
    openssh.authorizedKeys.keys = [ ];
  };

  programs.zsh.enable = true;
}
