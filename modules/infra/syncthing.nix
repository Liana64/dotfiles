# @desc: Syncthing device/folder topology shared by clients and m1
{
  config,
  user,
  ...
}: let
  net = config.flake.network;
in {
  flake.syncthing = {
    versioning = {
      type = "trashcan";
      params.cleanoutDays = "90";
    };

    devices = {
      framework.id = "GD6R65V-3NAAPLY-FMWVDMY-AHQGZEK-LZXXMAL-HKLP33W-J6CHSNF-O6BI6AY";
      maxine-framework.id = "WI6FCGN-NBVKCAD-7TC72I4-CFJ7TSA-LKKTXQW-Z22YJES-6CGUKMC-CSQ6LQQ";
      cluster = {
        id = "ENNUNJO-JHR527S-JMMU6IJ-UBA4CL6-CRRPWB4-2GOGD6X-DVIJNJY-DPJLPAR";
        addresses = ["tcp://${net.cluster.hosts.syncthing}:22000"];
      };
      m1 = {
        id = "DZMCSC2-3MUIPEU-SUXQXEH-OYRESED-DWAXB3H-O3ZTUUI-QN4VM4C-ZVUIHAB";
        addresses = ["tcp://${net.hstore.hosts.m1}:22000"];
      };
      # catbox = {
      #   id = "CATBOX-DEVICE-ID";
      #   addresses = ["tcp://${net.home.hosts.catbox}:22000"];
      # };
      # deck.id = "DECK-DEVICE-ID";
    };

    folders = let
      mine = ["m1" "framework" "cluster"];
      maxine = ["m1" "maxine-framework"];
      # games = ["m1" "catbox" "deck"];
    in {
      # "f3px7-gxjz7" = {
      #   label = "RetroDECK Saves";
      #   owner = "games";
      #   path = "retrodeck/saves";
      #   devices = games;
      # };
      # "zcmax-6gcj0" = {
      #   label = "RetroDECK States";
      #   owner = "games";
      #   path = "retrodeck/states";
      #   devices = games;
      # };
      "bddhy-7xeus" = {
        label = "${user.fullName} Projects";
        owner = user.name;
        path = "Projects";
        devices = mine;
        ignores = ["/External"];
      };
      "dqjzb-kwqzh" = {
        label = "${user.fullName} Photos";
        owner = user.name;
        path = "Media/Photos";
        devices = mine;
      };
      "pcem2-vtzke" = {
        label = "${user.fullName} Videos";
        owner = user.name;
        path = "Media/Videos";
        devices = mine;
      };
      "nnbty-vi2es" = {
        label = "${user.fullName} Screenshots";
        owner = user.name;
        path = "Media/Screenshots";
        devices = mine;
      };
      "etaus-cy9u5" = {
        label = "${user.fullName} Notebook";
        owner = user.name;
        path = "Notebook";
        devices = mine;
      };
      "itxfi-cig7x" = {
        label = "Shared Reference";
        owner = "shared";
        path = "Shared/Reference";
        devices = mine;
      };
      "kslaa-vounv" = {
        label = "${user.fullName} Documents";
        owner = user.name;
        path = "Documents";
        devices = mine;
      };
      "z443t-7mcjh" = {
        label = "${user.fullName} Pictures";
        owner = user.name;
        path = "Media/Pictures";
        devices = mine;
      };
      "zd95a-syzmp" = {
        label = "Shared Family";
        owner = "shared";
        path = "Shared/Family";
        devices = mine;
      };
      "grcx4-ny7sk" = {
        label = "Maxine Important Files";
        owner = "maxine";
        path = "Important";
        devices = maxine;
      };
      "vcvl6-co6q6" = {
        label = "Maxine Notebook";
        owner = "maxine";
        path = "Notebook";
        devices = maxine;
      };
    };
  };
}
