{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    neovim
    neovim-remote

    tree-sitter

    bash-language-server
    helm-ls
    lua-language-server
    nixd
    ruff
    rustup
    tombi
    typescript-language-server
    typos
    vscode-json-languageserver
    yaml-language-server

    alejandra
    biome
    buildifier
    nixfmt-rs
    shfmt
    stylua

    shellcheck
  ];

  my.outOfStoreSymlinks.config.nvim = "cli/nvim";

  my.hjem.environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };

  my.hjem.xdg.mime-apps = {
    added-associations = {
      "application/json" = "nvim.desktop";
    };
    default-applications = {
      "application/json" = "nvim.desktop";
      "text/*" = "nvim.desktop";
    };
  };
}
