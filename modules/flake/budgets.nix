# @desc: Token-budget tripwires on always-loaded agentic artifacts
{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) self;
  # these files ride into sessions; adopting a line at cap means pruning
  # one — additions are trades, not accumulation.
  budgets = {
    "modules/agentic/context/AGENTS.md" = 60;
    "CLAUDE.md" = 50;
    "modules/security/CLAUDE.md" = 25;
    "modules/bin/CLAUDE.md" = 25;
  };
in {
  perSystem = {pkgs, ...}: {
    checks.agents-budget = pkgs.runCommand "agents-budget" {} (
      lib.concatStrings (lib.mapAttrsToList (path: cap: ''
          n=$(wc -l < ${self + "/${path}"})
          if [ "$n" -gt ${toString cap} ]; then
            echo "${path} is $n lines, budget ${toString cap}: prune a line before adding one" >&2
            exit 1
          fi
        '')
        budgets)
      + "touch $out"
    );
  };
}
