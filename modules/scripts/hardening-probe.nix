# @desc: hardening-probe — run a command or live unit under a systemd-hardening preset
{...}: {
  flake.modules.homeManager.hardening-probe = {
    lib,
    pkgs,
    ...
  }: let
    deps = with pkgs; [systemd coreutils gnused gnugrep jq nix];
    hardening = import ../_lib/systemd-hardening.nix;
    toProps = preset: lib.concatStringsSep "\n" (hardening.lines preset);
    hardening-probe = pkgs.symlinkJoin {
      name = "hardening-probe";
      paths = [
        (pkgs.writeShellScriptBin "hardening-probe"
          (builtins.readFile ../bin/hardening-probe))
      ];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/hardening-probe \
          --prefix PATH : ${lib.makeBinPath deps} \
          --set HARDENING_BASE ${lib.escapeShellArg (toProps hardening.base)} \
          --set HARDENING_LAUNCH ${lib.escapeShellArg (toProps hardening.launch)} \
          --set HARDENING_CONFINED ${lib.escapeShellArg (toProps hardening.confined)} \
          --set HARDENING_AIRGAPPED ${lib.escapeShellArg (toProps hardening.airgapped)}
      '';
    };
  in {
    home.packages = [hardening-probe];
  };
}
