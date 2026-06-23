{ pkgs, lib, colors, ... }: let
  vault = "Notebook";

  # "#rrggbb" -> "r, g, b" for Obsidian's rgba() color variables.
  rgb = hex: let
    h = lib.toLower (lib.removePrefix "#" hex);
    d = c: {
      "0" = 0; "1" = 1; "2" = 2; "3" = 3; "4" = 4; "5" = 5; "6" = 6; "7" = 7;
      "8" = 8; "9" = 9; "a" = 10; "b" = 11; "c" = 12; "d" = 13; "e" = 14; "f" = 15;
    }.${c};
    byte = i: toString (d (builtins.substring i 1 h) * 16 + d (builtins.substring (i + 1) 1 h));
  in "${byte 0}, ${byte 2}, ${byte 4}";

  # Recolors the default theme: gruvbox character on the blueberry palette.
  blueberry = ''
    /* Blueberry — generated from obsidian.nix. */
    .theme-dark {
      --color-base-00: ${colors.background};
      --color-base-05: ${colors.background};
      --color-base-10: ${colors.mbg};
      --color-base-15: ${colors.mbg};
      --color-base-20: ${colors.mbg};
      --color-base-25: ${colors.gray};
      --color-base-30: ${colors.gray};
      --color-base-35: ${colors.gray};
      --color-base-40: ${colors.comment};
      --color-base-50: ${colors.comment};
      --color-base-60: ${colors.tan};
      --color-base-70: ${colors.tan};
      --color-base-100: ${colors.foreground};

      --color-red: ${colors.red};       --color-red-rgb: ${rgb colors.red};
      --color-orange: ${colors.orange}; --color-orange-rgb: ${rgb colors.orange};
      --color-yellow: ${colors.orange}; --color-yellow-rgb: ${rgb colors.orange};
      --color-green: ${colors.lime};    --color-green-rgb: ${rgb colors.lime};
      --color-cyan: ${colors.emerald};  --color-cyan-rgb: ${rgb colors.emerald};
      --color-blue: ${colors.highlight};   --color-blue-rgb: ${rgb colors.highlight};
      --color-purple: ${colors.pink};   --color-purple-rgb: ${rgb colors.pink};
      --color-pink: ${colors.pink};     --color-pink-rgb: ${rgb colors.pink};

      --h1-color: ${colors.emerald};
      --h2-color: ${colors.pink};
      --h3-color: ${colors.red};
      --h4-color: ${colors.orange};
      --h5-color: ${colors.lime};
      --h6-color: ${colors.green};
      --inline-title-color: ${colors.orange};

      --bold-color: ${colors.orange};
      --code-normal: ${colors.emerald};
      --link-external-color: ${colors.green};
      --blockquote-border-color: ${colors.highlight};

      --text-selection: rgba(${rgb colors.highlight}, 0.25);
      --text-highlight-bg: rgba(${rgb colors.orange}, 0.4);

      --tag-color: ${colors.emerald};
      --tag-background: rgba(${rgb colors.emerald}, 0.15);
    }

    body {
      --tag-radius: 0.5em;

      --callout-default: ${rgb colors.highlight};
      --callout-note: ${rgb colors.highlight};
      --callout-info: ${rgb colors.highlight};
      --callout-todo: ${rgb colors.highlight};
      --callout-summary: ${rgb colors.emerald};
      --callout-tip: ${rgb colors.emerald};
      --callout-important: ${rgb colors.emerald};
      --callout-success: ${rgb colors.lime};
      --callout-question: ${rgb colors.orange};
      --callout-warning: ${rgb colors.orange};
      --callout-fail: ${rgb colors.red};
      --callout-error: ${rgb colors.red};
      --callout-bug: ${rgb colors.red};
      --callout-example: ${rgb colors.pink};
      --callout-quote: ${rgb colors.comment};
    }
  '';

  # Core plugin enabled-state mirrored from the live vault. Single source for
  # both core-plugins.json and the module's plugin list.
  corePlugins = {
    file-explorer = true;
    global-search = true;
    switcher = true;
    graph = true;
    backlink = true;
    canvas = true;
    outgoing-link = true;
    tag-pane = true;
    footnotes = false;
    properties = false;
    page-preview = true;
    daily-notes = true;
    templates = true;
    note-composer = true;
    command-palette = true;
    slash-command = false;
    editor-status = true;
    bookmarks = true;
    markdown-importer = false;
    zk-prefixer = false;
    random-note = false;
    outline = true;
    word-count = true;
    slides = false;
    audio-recorder = false;
    workspaces = false;
    file-recovery = true;
    publish = false;
    sync = true;
    bases = true;
    webviewer = false;
  };
in {
  programs.obsidian = {
    enable = true;

    defaultSettings = {
      app.alwaysUpdateLinks = true;

      # Fonts mirror stylix.nix; accent is the desktop highlight.
      appearance = {
        baseFontSize = 16;
        theme = "obsidian";
        interfaceFontFamily = "Cantarell";
        monospaceFontFamily = "JetBrainsMono Nerd Font";
        accentColor = colors.highlight;
      };

      # `bases` is too new for the module's plugin enum; it rides along via the
      # core-plugins.json override below.
      corePlugins = lib.attrNames (lib.filterAttrs (_: v: v) (removeAttrs corePlugins [ "bases" ]));

      cssSnippets = [ { name = "Blueberry"; text = blueberry; } ];

      hotkeys = {
        "leader-hotkeys-obsidian:register-modal" = [{ modifiers = [ "Shift" ]; key = " "; }];
        "switcher:open" = [{ modifiers = [ "Mod" ]; key = " "; }];
        "obsidian-tasks-plugin:edit-task" = [{ modifiers = [ "Mod" "Shift" ]; key = "C"; }];
        "app:go-back" = [{ modifiers = [ "Mod" "Shift" ]; key = "A"; }];
        "app:go-forward" = [{ modifiers = [ "Mod" "Shift" ]; key = "D"; }];
      };
    };

    vaults.${vault} = { };
  };

  # Obsidian reads core-plugins.json as an object; the module emits an array.
  # Emit the real object so every plugin, `bases` included, survives.
  home.file."${vault}/.obsidian/core-plugins.json".source =
    lib.mkForce ((pkgs.formats.json { }).generate "core-plugins.json" corePlugins);

  # Clear real config so home-manager can link its own. Obsidian rewrites these
  # at runtime; back the original aside once, then discard later drift each run.
  home.activation.obsidianAdopt = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    d="$HOME/${vault}/.obsidian"
    for f in app.json appearance.json core-plugins.json core-plugins-migration.json community-plugins.json hotkeys.json; do
      if [ -e "$d/$f" ] && [ ! -L "$d/$f" ]; then
        if [ -e "$d/$f.pre-hm" ]; then rm "$d/$f"; else mv "$d/$f" "$d/$f.pre-hm"; fi
      fi
    done
  '';
}
