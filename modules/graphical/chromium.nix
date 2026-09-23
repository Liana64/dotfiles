# @desc: Chromium browsers
{...}: {
  flake.modules.homeManager.chromium = {nixpkgs-unstable, ...}: {
    home.packages = [
      (nixpkgs-unstable.ungoogled-chromium.override {
        commandLineArgs = "--ozone-platform=wayland";
      })
    ];
  };
}
