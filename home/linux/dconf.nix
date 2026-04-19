{...}: {
  dconf.settings = let
    fileChooser = {
      sort-directories-first = true;
      location-mode = "path-bar";
      startup-mode = "cwd";
      sort-column = "name";
      sort-order = "ascending";
      show-hidden = false;
      show-size-column = true;
      show-type-column = false;
    };
  in {
    "org/gtk/settings/file-chooser" = fileChooser;
    "org/gtk/gtk4/settings/file-chooser" = fileChooser;
  };
}
