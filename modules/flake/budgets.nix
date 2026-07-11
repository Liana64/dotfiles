# @desc: Token-budget tripwires on always-loaded agentic artifacts
{inputs, ...}: let
  inherit (inputs) self;
  # AGENTS.md rides into every session; adopting a directive at cap means
  # pruning one — additions are trades, not accumulation.
  agentsCap = 60;
in {
  perSystem = {pkgs, ...}: {
    checks.agents-budget = pkgs.runCommand "agents-budget" {} ''
      n=$(wc -l < ${self + "/modules/agentic/AGENTS.md"})
      if [ "$n" -gt ${toString agentsCap} ]; then
        echo "AGENTS.md is $n lines, budget ${toString agentsCap}: prune a directive before adding one" >&2
        exit 1
      fi
      touch $out
    '';
  };
}
