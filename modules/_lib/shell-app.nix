# @desc: modules/bin script → writeShellApplication; script keeps its own set flags, lint matches flake checks
pkgs: name: args:
pkgs.writeShellApplication ({
    inherit name;
    bashOptions = [];
    extraShellCheckFlags = ["-S" "warning"];
    text = builtins.readFile ../bin/${name};
  }
  // args)
