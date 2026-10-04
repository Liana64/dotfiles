{
  versioning = {
    type = "trashcan";
    params.cleanoutDays = "90";
  };

  devices = {
    framework.id = "GD6R65V-3NAAPLY-FMWVDMY-AHQGZEK-LZXXMAL-HKLP33W-J6CHSNF-O6BI6AY";
    cluster = {
      id = "ENNUNJO-JHR527S-JMMU6IJ-UBA4CL6-CRRPWB4-2GOGD6X-DVIJNJY-DPJLPAR";
      addresses = ["tcp://172.16.5.16:22000"];
    };
    m1 = {
      id = "DZMCSC2-3MUIPEU-SUXQXEH-OYRESED-DWAXB3H-O3ZTUUI-QN4VM4C-ZVUIHAB";
      addresses = ["tcp://172.16.20.44:22000"];
    };
  };

  folders = let
    liana = ["cluster" "framework" "m1"];
  in {
    "bddhy-7xeus" = {
      label = "Liana Projects";
      owner = "liana";
      path = "Projects";
      devices = liana;
    };
    "dqjzb-kwqzh" = {
      label = "Liana Photos";
      owner = "liana";
      path = "Media/Photos";
      devices = liana;
    };
    "etaus-cy9u5" = {
      label = "Liana Notebook";
      owner = "liana";
      path = "Notebook";
      devices = liana;
    };
    "itxfi-cig7x" = {
      label = "Shared Reference";
      owner = "shared";
      path = "Shared/Reference";
      devices = liana;
    };
    "kslaa-vounv" = {
      label = "Liana Documents";
      owner = "liana";
      path = "Documents";
      devices = liana;
    };
    "z443t-7mcjh" = {
      label = "Liana Pictures";
      owner = "liana";
      path = "Media/Pictures";
      devices = liana;
    };
    "zd95a-syzmp" = {
      label = "Shared Family";
      owner = "shared";
      path = "Shared/Family";
      devices = liana;
    };
    "liana-data" = {
      label = "Liana Data";
      owner = "liana";
      path = "Sync/Data";
      devices = liana;
    };
  };
}
