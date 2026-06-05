{ pkgs, lib, ... }:
let
  deps = with pkgs; [
    iperf3 iw ethtool bluez iputils networkmanager
    jq gawk gnused gnugrep coreutils util-linux pciutils iproute2
  ];
  scripts = [ "wifi-bench" ];
  bin = name: pkgs.writeShellScriptBin name
    (builtins.readFile (../../modules/linux/bin + "/${name}"));
  benchmarks = pkgs.symlinkJoin {
    name = "benchmarks";
    paths = map bin scripts;
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = lib.concatMapStrings (name: ''
      wrapProgram $out/bin/${name} --prefix PATH : ${lib.makeBinPath deps}
    '') scripts;
  };
in
{
  home.packages = [ benchmarks ];
}
