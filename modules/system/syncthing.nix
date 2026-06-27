# @desc: Syncthing
{...}: {
  flake.modules.homeManager.syncthing = {
    services.syncthing = {
      enable = true;
      overrideDevices = true;
      overrideFolders = true;

      guiCredentials = {
        username = "admin";
        passwordFile = "/var/secrets/syncthing/gui-passwd";
      };

      settings = {
        devices = {
          "Milberry Cluster" = {
            id = "ENNUNJO-JHR527S-JMMU6IJ-UBA4CL6-CRRPWB4-2GOGD6X-DVIJNJY-DPJLPAR";
            addresses = ["tcp://172.16.5.16:22000"];
          };
        };

        folders = {
          "bddhy-7xeus" = {
            label = "Liana Projects";
            path = "~/Projects";
            devices = ["Milberry Cluster"];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "90";
            };
          };

          "dqjzb-kwqzh" = {
            label = "Liana Photos";
            path = "~/Media/Photos";
            devices = ["Milberry Cluster"];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "90";
            };
          };

          "etaus-cy9u5" = {
            label = "Liana Notebook";
            path = "~/Notebook";
            devices = ["Milberry Cluster"];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "90";
            };
          };

          "itxfi-cig7x" = {
            label = "Shared Reference";
            path = "~/Reference";
            devices = ["Milberry Cluster"];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "90";
            };
          };

          "kslaa-vounv" = {
            label = "Liana Documents";
            path = "~/Documents";
            devices = ["Milberry Cluster"];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "90";
            };
          };

          "z443t-7mcjh" = {
            label = "Liana Pictures";
            path = "~/Media/Pictures";
            devices = ["Milberry Cluster"];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "90";
            };
          };

          "zd95a-syzmp" = {
            label = "Shared Family";
            path = "~/Documents/Family";
            devices = ["Milberry Cluster"];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "90";
            };
          };

          "liana-data" = {
            label = "Liana Data";
            path = "~/Sync/Data";
            devices = ["Milberry Cluster"];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "90";
            };
          };
        };

        options = {
          urAccepted = -1;
        };
      };
    };

    # SQLite sidecars must never sync — live WAL/shared-memory files tear across
    # peers. taskchampion.sqlite3 itself rides along as a single-writer backup.
    home.file."Sync/Data/.stignore".text = ''
      *-wal
      *-shm
      *-journal
      *.log
    '';
  };
}
