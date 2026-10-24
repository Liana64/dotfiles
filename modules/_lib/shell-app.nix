# @desc: modules/bin script → writeShellApplication
pkgs: name: args:
pkgs.writeShellApplication ({
    inherit name;
    bashOptions = [];
    extraShellCheckFlags = ["-S" "warning"];
    text = builtins.readFile ../bin/${name};
  }
  // args)
