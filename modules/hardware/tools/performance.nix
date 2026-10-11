_: {
  flake.modules.nixos.perfTools = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      perf # Benchmarking
      stress-ng # Burn-in
      fio # Storage benchmarking
    ];
  };
}
