_: {
  perSystem = {pkgs, ...}: {
    devShells.haskell = pkgs.mkShell {
      packages = with pkgs; [
        cabal-install
        ghc
        haskell-language-server
        hlint
        ormolu
      ];
    };
  };

  flake.modules.homeManager.helix = {
    programs.helix.languages.language = [
      {
        name = "haskell";
        auto-format = true;
      }
    ];
  };
}
