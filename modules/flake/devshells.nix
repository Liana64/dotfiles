# @desc: Dev shells (nix develop .#infra|rust) — project toolchains kept off the global profile
{...}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    devShells = {
      infra = pkgs.mkShell {
        packages = with pkgs;
          [
            age
            ansible
            ansible-lint
            cilium-cli
            fluxcd
            gitleaks
            go-task
            helmfile
            jq
            ktop
            kubeconform
            kubectl
            kubernetes-helm
            kustomize
            opentofu
            pre-commit
            sops
            talosctl
            yq-go
          ]
          ++ [inputs'.nixpkgs-unstable.legacyPackages.talhelper];
      };

      rust = pkgs.mkShell {
        packages = with pkgs; [
          cargo
          rustc
          clippy
          rustfmt
          rust-analyzer
        ];
      };
    };
  };
}
