# @desc: persist-diff — ephemeral-root files that would vanish on reboot
{...}: {
  flake.modules.homeManager.persist-diff = {
    lib,
    pkgs,
    ...
  }: let
    deps = with pkgs; [btrfs-progs coreutils gnused util-linux];
    script =
      pkgs.writeShellScriptBin "persist-diff"
      (builtins.readFile ../bin/persist-diff);
    persist-diff = pkgs.symlinkJoin {
      name = "persist-diff";
      paths = [script];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/persist-diff --prefix PATH : ${lib.makeBinPath deps}
      '';
    };
  in {
    home.packages = [persist-diff];
  };
}
