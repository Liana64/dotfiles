# @desc: Signal Desktop
{...}: {
  flake.modules.homeManager.signal = {
    pkgs,
    nixpkgs-unstable,
    ...
  }: {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "signal-desktop";
        paths = [nixpkgs-unstable.signal-desktop];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = "wrapProgram $out/bin/signal-desktop --add-flags --password-store=gnome-libsecret";
      })
    ];
  };
}
