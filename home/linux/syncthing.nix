{
  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices = {
        "Milberry Cluster" = {
          id = "ENNUNJO-JHR527S-JMMU6IJ-UBA4CL6-CRRPWB4-2GOGD6X-DVIJNJY-DPJLPAR";
          addresses = [ "tcp://172.16.5.16:22000" ];
        };
      };

      folders = {
        "bddhy-7xeus" = {
          label = "Liana Projects";
          path = "~/Projects";
          devices = [ "Milberry Cluster" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };

        "dqjzb-kwqzh" = {
          label = "Liana Photos";
          path = "~/Media/Photos";
          devices = [ "Milberry Cluster" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };

        "etaus-cy9u5" = {
          label = "Liana Notebook";
          path = "~/Notebook";
          devices = [ "Milberry Cluster" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };

        "itxfi-cig7x" = {
          label = "Shared Reference";
          path = "~/Reference";
          devices = [ "Milberry Cluster" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };

        "kslaa-vounv" = {
          label = "Liana Documents";
          path = "~/Documents";
          devices = [ "Milberry Cluster" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };

        "z443t-7mcjh" = {
          label = "Liana Pictures";
          path = "~/Media/Pictures";
          devices = [ "Milberry Cluster" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };

        "zd95a-syzmp" = {
          label = "Shared Family";
          path = "~/Documents/Family";
          devices = [ "Milberry Cluster" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };
      };

      gui = {
        address = "127.0.0.1:8384";
        user = "admin";
        theme = "dark";
      };

      options = {
        urAccepted = -1;
      };
    };
  };
}
