# @desc: home-infra pre-commit hook set (wired into the infra devshell only)
{inputs, ...}: {
  imports = [inputs.git-hooks.flakeModule];

  perSystem = {pkgs, ...}: {
    pre-commit = {
      check.enable = false;

      settings = {
        default_stages = ["pre-commit" "pre-push"];

        hooks = {
          check-merge-conflicts.enable = true;
          end-of-file-fixer.enable = true;
          mixed-line-endings.enable = true;

          trim-trailing-whitespace = {
            enable = true;
            args = ["--markdown-linebreak-ext=md"];
          };

          forbid-unencrypted-sops = {
            enable = true;
            name = "Check *.sops.yaml files are encrypted";
            entry = toString (pkgs.writeShellScript "forbid-unencrypted-sops" ''
              export PATH="${pkgs.sops}/bin:$PATH"
              exec ./scripts/check-sops-encrypted.sh "$@"
            '');
            language = "system";
            files = "\\.sops\\.ya?ml$";
            excludes = ["^\\.sops\\.ya?ml$" "^\\.claude/templates/"];
          };

          forbid-k8s-secrets = {
            enable = true;
            name = "Check for unencrypted Kubernetes secrets in manifests";
            entry = "scripts/check-k8s-secrets-encrypted.sh";
            language = "script";
            files = "\\.ya?ml$";
            excludes = ["rbac\\.yaml" "^\\.claude/templates/"];
          };

          gitleaks = {
            enable = true;
            name = "Detect hardcoded secrets";
            entry = "${pkgs.gitleaks}/bin/gitleaks git --pre-commit --redact --staged --verbose";
            language = "system";
            pass_filenames = false;
          };
        };
      };
    };
  };
}
