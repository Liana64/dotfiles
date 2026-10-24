# @desc: netshoot — cluster-side connectivity checks through the netshoot pod
_: {
  flake.modules.homeManager.netshoot = {pkgs, ...}: {
    home.packages = [
      (import ../_lib/shell-app.nix pkgs "netshoot" {runtimeInputs = [pkgs.kubectl];})
    ];
  };
}
