# @desc: libudev whose chase() opens / O_PATH, so landlocked houses can enumerate hidraw (systemd#41630, fixed in 261)
pkgs:
pkgs.udev.overrideAttrs (old: {
  patches = (old.patches or []) ++ [../../patches/0003-systemd-open-host-root-O_PATH-in-chaseat.patch];
})
