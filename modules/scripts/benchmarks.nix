# @desc: wifi-bench / bt-bench wrappers with bundled deps
{...}: {
  flake.modules.homeManager.benchmarks = {pkgs, ...}: {
    home.packages = map (name:
      import ../_lib/shell-app.nix pkgs name {
        runtimeInputs = with pkgs; [
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
      }) ["wifi-bench" "bt-bench"];
  };
}
