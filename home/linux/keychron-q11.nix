{ pkgs, lib, ... }:
let
  keymap = ../../embedded/keychron-q11;
  deps = with pkgs; [ git qmk gnumake gcc-arm-embedded dfu-util coreutils ];
  name = "keychron-q11";
  keychron-q11 = pkgs.symlinkJoin {
    inherit name;
    paths = [
      (pkgs.writeShellScriptBin name
        (builtins.readFile ../../modules/linux/bin/keychron-q11))
    ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/${name} \
        --prefix PATH : ${lib.makeBinPath deps} \
        --set KEYMAP_DIR ${keymap}
    '';
  };
in
{
  home.packages = [ keychron-q11 ];
}
