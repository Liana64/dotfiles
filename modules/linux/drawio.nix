{ pkgs, ... }: {
  environment.systemPackages = [
    (pkgs.symlinkJoin {
      name = "drawio-wrapped";
      paths = [ pkgs.drawio ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/drawio \
          --add-flags "--enable-gpu-rasterization"
      '';
    })
  ];
}
