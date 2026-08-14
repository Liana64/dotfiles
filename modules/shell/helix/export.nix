# @desc: helix-portable — nix-free helix config tarball (nix build .#helix-portable)
{config, ...}: {
  flake.modules.homeManager.helix = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellScriptBin "helix-export" (builtins.readFile ../../bin/helix-export))
    ];
  };

  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    hm = config.flake.homeConfigurations."liana@framework".config;
    inherit (hm.programs.helix) languages;

    servers = builtins.removeAttrs languages.language-server ["nixd"];

    dropSchemas = srv: srv // {config = srv.config // {yaml = builtins.removeAttrs srv.config.yaml ["schemas"];};};

    portable = lib.filterAttrs (_: v: v != []) (
      languages
      // {
        language-server = servers // {yaml-language-server = dropSchemas servers.yaml-language-server;};
        language = builtins.filter (l: l.name != "nix") languages.language;
      }
    );

    toml = pkgs.formats.toml {};
  in {
    packages.helix-portable = pkgs.runCommand "helix-config.tar.gz" {} ''
      mkdir -p helix/themes
      cp ${hm.xdg.configFile."helix/config.toml".source} helix/config.toml
      cp ${toml.generate "languages.toml" portable} helix/languages.toml
      cp ${hm.xdg.configFile."helix/themes/kanagawa-dim.toml".source} helix/themes/kanagawa-dim.toml
      tar --owner=0 --group=0 --mode=u+w -czf $out helix
    '';
  };
}
