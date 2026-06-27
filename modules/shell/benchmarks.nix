# @desc: wifi-bench / bt-bench wrappers with bundled deps
{...}: {
  flake.modules.homeManager.benchmarks = {
    pkgs,
    lib,
    ...
  }: let
    deps = with pkgs; [
      iperf3
      iw
      ethtool
      bluez
      iputils
      networkmanager
      pulseaudio
      jq
      gawk
      gnused
      gnugrep
      coreutils
      util-linux
      findutils
      pciutils
      iproute2
    ];
    scripts = ["wifi-bench" "bt-bench"];
    bin = name:
      pkgs.writeShellScriptBin name
      (builtins.readFile (../../modules/bin + "/${name}"));
    benchmarks = pkgs.symlinkJoin {
      name = "benchmarks";
      paths = map bin scripts;
      buildInputs = [pkgs.makeWrapper];
      postBuild =
        lib.concatMapStrings (name: ''
          wrapProgram $out/bin/${name} --prefix PATH : ${lib.makeBinPath deps}
        '')
        scripts;
    };
  in {
    home.packages = [benchmarks];
  };
}
