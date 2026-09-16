{...}: {
  flake.modules.homeManager = {
    helix = {
      pkgs,
      lib,
      ...
    }: {
      programs.helix = {
        extraPackages = [pkgs.bash-language-server];

        languages.language = [
          {
            name = "bash";
            formatter = {
              command = lib.getExe pkgs.shfmt;
              args = ["-i" "2" "-ci" "-"];
            };
          }
        ];
      };
    };

    devPackages = {pkgs, ...}: {
      home.packages = with pkgs; [shellcheck shfmt];
    };
  };
}
