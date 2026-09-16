# Credit: https://github.com/Anomalocaridid/dotfiles/blob/43ee161efd20091009bc7833a230bb1dcc92a301/modules/development/languages/go.nix
_: {
  perSystem = {pkgs, ...}: {
    devShells.go = pkgs.mkShell {
      packages = with pkgs; [
        delve
        go
        golangci-lint
        golangci-lint-langserver
        gopls
        gotools
      ];
    };
  };

  flake.modules.homeManager.helix = {
    pkgs,
    lib,
    ...
  }: {
    programs.helix = {
      extraPackages = [pkgs.gopls];

      languages.language = [
        {
          name = "go";
          auto-format = true;
          formatter.command = lib.getExe' pkgs.gotools "goimports";
        }
      ];
    };
  };
}
