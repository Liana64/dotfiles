---
name: quick-lint
description: Fast lint check using the cheapest model
model: haiku
effort: low
allowed-tools: Bash, Read
argument-hint: "[file]"
---
Run the project linter on: $ARGUMENTS
Detect the linter from config (eslint, ruff, clippy) and run it. Report only errors, not warnings.
