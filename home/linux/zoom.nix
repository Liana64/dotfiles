# @desc: Zoom (web client via Firefox)
{
  pkgs,
  config,
  ...
}: let
  zoom-web = pkgs.symlinkJoin {
    name = "zoom-web";
    paths = [(pkgs.writeShellScriptBin "zoom-web" (builtins.readFile ../../modules/linux/bin/zoom-web))];
    buildInputs = [pkgs.makeWrapper];
    postBuild = "wrapProgram $out/bin/zoom-web --prefix PATH : ${config.programs.firefox.finalPackage}/bin";
  };
in {
  home.packages = [zoom-web];

  # No icon: none exists on this setup. The entry registers the zoommtg://
  # scheme handler (see mime.nix) and surfaces "Zoom" in the vicinae launcher.
  xdg.desktopEntries."zoom-web" = {
    name = "Zoom";
    genericName = "Zoom (web client)";
    exec = "${zoom-web}/bin/zoom-web %u";
    terminal = false;
    type = "Application";
    categories = ["Network" "AudioVideo"];
    mimeType = ["x-scheme-handler/zoommtg" "x-scheme-handler/zoomus"];
    startupNotify = true;
  };
}
