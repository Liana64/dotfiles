# @desc: ssh client config
{...}: {
  flake.modules.homeManager.ssh = {...}: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        IdentityFile = ["~/.ssh/id_yk1" "~/.ssh/id_yk2"];
        IdentitiesOnly = true;
      };
    };
  };
}
