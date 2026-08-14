# @desc: Code formatter (alejandra)
{...}: {
  perSystem = {pkgs, ...}: {
    formatter = pkgs.symlinkJoin {
      name = "alejandra";
      paths = [pkgs.alejandra];
      buildInputs = [pkgs.makeWrapper];
      postBuild = "wrapProgram $out/bin/alejandra --add-flags -q";
      meta.mainProgram = "alejandra";
    };
  };
}
