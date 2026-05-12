{ config, ... }: {
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    documents = "${config.home.homeDirectory}/Documents";
    download  = "${config.home.homeDirectory}/Downloads";
    pictures  = "${config.home.homeDirectory}/Media/Pictures";
    videos    = "${config.home.homeDirectory}/Media/Videos";

    desktop     = null;
    music       = null;
    publicShare = null;
    templates   = null;

    extraConfig = {
      XDG_NOTEBOOK_DIR  = "${config.home.homeDirectory}/Notebook";
      XDG_REFERENCE_DIR = "${config.home.homeDirectory}/Reference";
      XDG_PROJECTS_DIR  = "${config.home.homeDirectory}/Projects";
      XDG_BACKUPS_DIR   = "${config.home.homeDirectory}/Backups";
      XDG_MEDIA_DIR     = "${config.home.homeDirectory}/Media";
    };
  };
}
