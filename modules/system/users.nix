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

    programs.zsh = {
      enable = true;
      shellInit = "zsh-newuser-install() { :; }";
      interactiveShellInit = ''
        bindkey '^[[1;5C' forward-word
        bindkey '^[[1;5D' backward-word
        bindkey '^[[1;3C' forward-word
        bindkey '^[[1;3D' backward-word
        bindkey '^[[H' beginning-of-line
        bindkey '^[[F' end-of-line
        bindkey '^[[3~' delete-char
      '';
    };

    programs.vim.enable = true;
  };
}
