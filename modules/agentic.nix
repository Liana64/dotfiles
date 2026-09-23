# @desc: Claude Code harness — the agentic flake wired into this config
{inputs, ...}: {
  flake.modules.homeManager.agentic = {
    lib,
    nixpkgs-unstable,
    ...
  }: let
    hardening = import ./_lib/systemd-hardening.nix;

    cargoDevshell =
      lib.concatMap
      (sel:
        lib.concatMap (cmd: [
          "Bash(nix develop ${sel}-c cargo ${cmd})"
          "Bash(nix develop ${sel}-c cargo ${cmd} *)"
        ]) ["build" "check" "clippy" "fmt" "test"])
      ["" ". "];
  in {
    imports = [inputs.agentic.homeModules.agentic];

    agentic = {
      enable = true;
      package = nixpkgs-unstable.claude-code;
      # host tooling the base list cannot know about; nix develop -c pins only cargo
      permissions.allow =
        [
          "Bash(ai-todo *)"
          "Bash(boltctl domains *)"
          "Bash(boltctl list *)"
          "Bash(cilium status *)"
          "Bash(dotfiles-verify)"
          "Bash(dotfiles-verify *)"
          "Bash(flux --context milberry get *)"
          "Bash(flux get *)"
          "Bash(flux logs *)"
          "Bash(flux tree *)"
          "Bash(helm history *)"
          "Bash(helm list *)"
          "Bash(helm status *)"
          "Bash(infra)"
          "Bash(infra list)"
          "Bash(kubectl describe *)"
          "Bash(kubectl get *)"
          "Bash(kubectl logs *)"
          "Bash(kubectl top *)"
          "Read(~/Notebook/Files/18 Recipes/**)"
        ]
        ++ cargoDevshell;
      # ProtectHome hides /run/user with it, severing the session bus;
      # tmpfs + bind exposes only the socket (verified: hardening-probe)
      serviceHardening =
        hardening.airgapped
        // {
          ProtectHome = "tmpfs";
          BindPaths = ["%t/bus"];
        };
    };
  };
}
