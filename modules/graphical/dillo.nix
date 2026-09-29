# @desc: Gemini client
{...}: {
  flake.modules.homeManager.dillo = {pkgs, ...}: {
    home.packages = [
      ((pkgs.dillo.override {fltk_1_3 = pkgs.fltk_1_4;}).overrideAttrs (o: {
        configureFlags = (o.configureFlags or []) ++ ["--enable-experimental-fltk"];
      }))
    ];
  };
}
