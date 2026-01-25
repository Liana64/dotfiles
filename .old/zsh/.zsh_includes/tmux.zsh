export WORKSPACES="lcl,vim,ctl,mon,rmt"

ln_load_tmux() {
  local quiet_mode="$1"
  local workspaces

  IFS=',' read -r -A workspaces <<< "$WORKSPACES"
  for workspace in "${workspaces[@]}"; do
    tmux new -d -s "$workspace"
    #echo "Created tmux workspace: $workspace"
  done

  if [[ "$quiet_mode" != "q" ]]; then
    echo "Finished creating workspaces"
  fi
}
