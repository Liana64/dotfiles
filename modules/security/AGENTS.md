# Security modules

Hardening (kernel params, usbguard, portal masking, module blacklists) is intentional — don't relax it to fix symptoms; root-cause first.

Prove any per-unit exception minimal with `hardening-probe`:
- `--live <unit>` against the deployed unit (preferred).
- `--count` behavior gate for maintenance jobs whose failure mode is doing less — exit codes lie.
- `--sweep` to name the culprit directive.

Wired-but-unproven hardening stays unstaged. Systemd presets live in `modules/_lib/systemd-hardening.nix`.
