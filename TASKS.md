# Tasks subsystem map

Verbatim output of a full exploration of the task-manager wiring (2026-07-17),
kept so that sweep never needs re-running. The addendum at the bottom records
what changed when the reminder-timer split landed.

---

## Overview: how the task/todoist selection is wired

The selector is a single NixOS option `taskManager` (enum `"taskwarrior"` | `"todoist"`, default `taskwarrior`). It is read by graphical/shell home modules via `osConfig.taskManager or "taskwarrior"` (the `or` fallback covers the standalone `homeConfigurations` case where `osConfig` is absent). On the live host it is set to **`todoist`**.

Key fact for your change: **all** homeManager modules are imported unconditionally for every host (`homeAspects = lib.attrValues config.flake.modules.homeManager`, `modules/flake/hosts.nix:11,56`). So the taskwarrior reminder timers currently run **even when `taskManager = "todoist"`** — that is the un-split gap.

---

## 1. The task systemd timers

`/nix/dotfiles/modules/shell/_taskwarrior/reminders.nix` — this is "the task systemd timer" (two user timers + two oneshot services). Imported by `taskwarrior.nix` (`imports = [... ./_taskwarrior/reminders.nix]`, `modules/shell/taskwarrior.nix:26-30`). It takes only `{pkgs, ...}:` today — no `osConfig`, no `taskManager` awareness.

- `task-due-reminder`: polls Taskwarrior every 10 min, notifies on tasks entering a 10-min due window.
  - `Timer.OnCalendar = "*:0/10"`, `Persistent = false`, `WantedBy = ["timers.target"]`
  - Service: `hardening.base`, `Type=oneshot`, runs `dueScript` (calls `task ... due.after:now due.before:$cutoff export | jq | notify-send`)
- `task-daily-digest`: morning agenda notification of overdue+today.
  - `Timer.OnCalendar = "*-*-* 08:00:00"`, `Persistent = true`
  - Service: `hardening.base`, `Type=oneshot`, runs `digestScript` (`task ... '(+OVERDUE or +TODAY)' export | jq | notify-send`)

Both scripts hardcode `pkgs.taskwarrior3`, `pkgs.jq`, `pkgs.libnotify`, `pkgs.coreutils`. Neither consults `taskManager`.

Other timers in the repo (unrelated to tasks): `insights-reminder` (`modules/agentic/agentic.nix:310`, monthly) and `store-verify` (`modules/security/store-verify.nix:35`, weekly).

---

## 2. The `taskManager` option — `modules/features/tasks.nix`

Note: it is a single file `modules/features/tasks.nix`, not a `tasks/` directory.

```nix
flake.modules.nixos.tasks = {lib, ...}: {
  options.taskManager = lib.mkOption {
    type = lib.types.enum ["taskwarrior" "todoist"];
    default = "taskwarrior";
    description = "Task manager surfaced in the bar. Todoist runs as a flatpak either way.";
  };
};
flake.modules.homeManager.todoist = {pkgs, lib, osConfig, ...}: {
  home.packages = lib.mkIf ((osConfig.taskManager or "taskwarrior") == "todoist") [pkgs.todoist];
};
```

So the `todoist` CLI (`pkgs.todoist` = sachaos Go CLI) is installed **only** when selected. Consumed in: `waybar.nix`, `sway.nix`, `_niri.nix` (all via `osConfig.taskManager or "taskwarrior"`), set per-host in `hosts/framework/options.nix:8`.

---

## 3. `modules/bin/waybar-task` (working tree, recently modified) + waybar wiring

Full script (`/nix/dotfiles/modules/bin/waybar-task`): POSIX `sh`, gated by a hide flag `$XDG_RUNTIME_DIR/waybar-task-hidden`. Shows the active Taskwarrior task (`+ACTIVE export | jq ... sort_by(.modified)|last`) with `▶` and class `active`; otherwise computes due/overdue counts by local **calendar day** (offset math in jq) and emits `{text,class,tooltip}` with class `due-today`/`overdue`. Pure taskwarrior + jq; no todoist logic.

Wiring in `/nix/dotfiles/modules/graphical/waybar.nix`:
- Both scripts are baked into the `waybar-scripts` `symlinkJoin` via `writeShellScriptBin ... builtins.readFile` (lines 23 & 26).
- PATH deps wrapped in `postBuild`:
  - `waybar-task` → `taskwarrior3 jq coreutils` (line 35)
  - `waybar-todoist` → `todoist jq coreutils gnused gawk` (line 38)
- The `custom/task` module is **already split** on `taskManager` (lines 400-419): if `todoist` → `exec waybar-todoist`, `interval=30`, on-click launches the Todoist flatpak; else → `exec waybar-task`, `interval=10`, on-click launches `taskwarrior-tui`. Both listen on `signal=9`.
- The waybar service grants todoist cache write: `ReadWritePaths = "%t %h/.cache/todoist"` (line 63), and CSS classes `active`/`due-today`/`overdue` are shared (lines 155-166).

---

## 4. Existing todoist tooling — `modules/bin/waybar-todoist`

`/nix/dotfiles/modules/bin/waybar-todoist` is the pattern you'd mirror for a todoist reminder. Key mechanics:
- Token gate: exits if `~/.config/todoist/config.json` is absent (avoids the CLI's interactive token prompt).
- `todoist sync` refreshes `~/.cache/todoist/cache.json`.
- Assignee filtering: the CLI filter grammar has no assignee predicate, so it reads `cache.json` with `jq` to exclude items whose `responsible_uid` isn't the user (`.user.id`), then filters them out of `todoist --csv list --filter <F>` output (CSV columns `id,priority,due,project,labels,content`).
- Filters used: `"overdue & !today"` then `"today"`, mapping to classes `overdue`/`due-today` with `rel` text.

Other todoist references (all launch the flatpak `com.todoist.Todoist`, not the CLI): `sway.nix:13-14,104,288`, `_niri.nix:13-14,212`, `flatpak.nix:46` (installed unconditionally). `config.nix:75,119,151` only mentions Todoist in comments — the Taskwarrior config is styled to mirror Todoist views/projects/priorities.

**No API token is managed by nix/sops.** `secrets.nix` has no todoist entry — the token in `~/.config/todoist/config.json` is created out-of-band by the CLI; `waybar-todoist` just checks for its existence.

---

## 5. Other `modules/bin` scripts referencing task/taskwarrior

- `waybar-task`, `waybar-todoist` (above).
- No other standalone bin script references tasks; the task keybind helpers live inline in `sway.nix` (`writeShellScript`): `task-display-toggle` (toggles the `waybar-task-hidden` flag, `pkill -RTMIN+9 waybar`), `task-start-stop`, `task-add`, `task-done` (`modules/graphical/sway.nix:33-66`) — all taskwarrior-only. taskwarrior CLI helpers (`tw`, `ai-todo`, `task-snooze`, `subtask`, `workon`) are `writeShellScriptBin` in `modules/shell/taskwarrior.nix:35-84`.

---

## 6. Secrets pattern — `modules/security/secrets.nix`

sops-nix + age. Secrets declared as `sops.secrets."<path>" = { path = "/var/secrets/..."; owner = "liana"; mode = "0400"; };` decrypted from `${inputs.secrets}/secrets.yaml` with age key at `/var/lib/sops-nix/key.txt` (PQ identity, cached in the kernel keyring by `editorKey`). Existing secrets: `wireguard/*`, `eek/gateway-key`, `syncthing/gui-passwd`, canary `test`. **No todoist secret exists.** If you wanted the reminder timer to run headless without relying on a hand-created `config.json`, this is where a `todoist/api-token` secret would be added — but the current codebase deliberately keeps the todoist token unmanaged and gates on `config.json` existence instead.

---

## The split gap for your planned change

Already split on `taskManager`: waybar `custom/task` module, sway/niri `taskApp` launch keybinds, the todoist CLI install.

**Not split (your target):** `modules/shell/_taskwarrior/reminders.nix` unconditionally installs the two Taskwarrior timers, so on the `todoist` host they fire pointless taskwarrior queries and produce no relevant notifications. To close it you'd make the reminder timers `taskManager`-aware. Natural options within the dendritic pattern:

- Add `osConfig` (+ `lib`) to `reminders.nix` and branch the `ExecStart` scripts / gate the units on `osConfig.taskManager or "taskwarrior"`, adding a todoist digest/due script that mirrors `waybar-todoist` (token gate on `~/.config/todoist/config.json`, `todoist sync`, `todoist --csv list --filter "today"/"overdue & !today"` + assignee filter, piped to `notify-send`). Note `reminders.nix` is imported by the always-on `taskwarrior` home module, so gating must be inside it (or move the timer into a `taskManager`-aware leaf like `features/tasks.nix`).
- Hardening: the todoist variant needs network egress (sync) and `~/.cache/todoist` + `~/.config/todoist` read/write; the current services use `hardening.base` (from `modules/_lib/systemd-hardening.nix`), which does not set `ProtectHome`, so home is reachable — but confirm no stricter directive blocks the network. `notify-send` (dbus) already works under `base` for the existing services.
- Deps for a todoist script: `todoist jq coreutils gnused gawk libnotify` (mirror the waybar-todoist wrap set plus `libnotify`).
