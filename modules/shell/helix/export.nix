# @desc: helix-portable — nix-free helix config tarball (nix build .#helix-portable)
{config, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    hm = config.flake.homeConfigurations."liana@framework".config;
    inherit (hm.programs.helix) languages;

    portable = lib.filterAttrs (_: v: v != []) (
      languages
      // {
        language-server = builtins.removeAttrs languages.language-server ["nixd"];
        language = builtins.filter (l: l.name != "nix") languages.language;
      }
    );

    toml = pkgs.formats.toml {};
  in {
    packages.helix-portable = pkgs.runCommand "helix-config.tar.gz" {} ''
      mkdir helix
      cp ${hm.xdg.configFile."helix/config.toml".source} helix/config.toml
      cp ${toml.generate "languages.toml" portable} helix/languages.toml
      tar --owner=0 --group=0 --mode=u+w -czf $out helix
    '';
  };
}
