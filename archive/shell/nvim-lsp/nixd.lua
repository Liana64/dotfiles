---@type vim.lsp.Config
return {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
  settings = {
    nixd = {
      nixpkgs = { expr = 'import (builtins.getFlake "/nix/dotfiles").inputs.nixpkgs { }' },
      options = {
        nixos = { expr = '(builtins.getFlake "/nix/dotfiles").nixosConfigurations.framework.options' },
        home_manager = {
          expr = '(builtins.getFlake "/nix/dotfiles").homeConfigurations."liana@framework".options',
        },
      },
    },
  },
}
