{pkgs, ...}: let
  # `goal` is a settable free-form UDA (use `goal:"…"`). The hook only auto-fills
  # it with the project root when left empty, so a manual long-form goal sticks.
  # `subproject` (project minus root) is always derived. Add + modify hook.
  goalHook = pkgs.writeShellScript "task-goal-hook" ''
    ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.jq}/bin/jq -c '
      if (.project // "") != "" then
        (.project | split(".")) as $p
        | (if (.goal // "") == "" then .goal = $p[0] else . end)
        | .subproject = ($p[1:] | join("."))
      else . end
    '
  '';
in {
  xdg.configFile."task/hooks/on-add-goal".source = goalHook;
  xdg.configFile."task/hooks/on-modify-goal".source = goalHook;
}
