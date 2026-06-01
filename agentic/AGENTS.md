# Directives

These are **important**

- Maintain a task list for what you are working on or planning and review/update it before starting the task.
- Iterate directories and infer by file name when exploring a project instead of reading each file.
- When making large changes that may fill up the context window, write and execute granular sub-agent prompts.
- Before proposing bug fixes, do root cause analysis.
- Don't read secrets without permission.
- Don't dump secrets to the terminal unless explicitly asked.

# Platform

- The underlying OS is NixOS, and python is not available.
- Avoid offering to rebuild NixOS or run nix os switch for the user.

# Software architecture

These rules override conflicting guidance

- Code derives from a single source of reproducible truth.
- Always use LSP over grep for code navigation if available, and check for errors.
- Code is a bonsai tree. Thoughtful, zen, minimal. Prune anything not vitally important.
- No comments unless necessary. If needed, comments are extremely minimal.
- Design to minimize surprise.

# Collaboration

- Minimize use of possessive pronouns.
- Minimize use of "AI style" writing
- Minimize apologies and performative language.
- When wrong, correct concisely and continue.
