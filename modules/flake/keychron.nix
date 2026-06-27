# @desc: Keychron Q11 firmware builder/flasher (nix run .#keychron-q11)
{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    keychron-q11 = pkgs.symlinkJoin {
      name = "keychron-q11";
      paths = [
        (pkgs.writeShellScriptBin "keychron-q11"
          (builtins.readFile ../bin/keychron-q11))
      ];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/keychron-q11 \
          --prefix PATH : ${lib.makeBinPath (with pkgs; [git qmk gnumake gcc-arm-embedded dfu-util coreutils])} \
          --set KEYMAP_DIR ${../../embedded/keychron-q11} \
          --set QMK_SRC ${inputs.qmk-firmware}
      '';
    };
  in {
    packages.keychron-q11 = keychron-q11;
    apps.keychron-q11 = {
      type = "app";
      program = "${keychron-q11}/bin/keychron-q11";
    };
  };
}
