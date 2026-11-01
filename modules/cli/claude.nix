{pkgs, ...}: {
  my.jails.claude = {
    enable = true;
    bootstrapService.enable = false;
    package = pkgs.claude-code;
    permissions = combinators:
      with combinators; [
        network

        # nix:
        (add-pkg-deps [pkgs.nix])
        (readonly "/nix/store")
        (readonly "/nix/var/nix")
        (readonly "/etc/nix/nix.conf")
        (ro-bind "${pkgs.nix-ld}/libexec/nix-ld" "/lib64/ld-linux-x86-64.so.2")

        # direnv:
        (add-pkg-deps [pkgs.direnv])
        (wrap-entry (entry: ''
          direnv exec . ${entry}
        ''))
        (readonly (noescape "~/.config/direnv"))
        (mkdir-readonly (noescape "~/.local/share/direnv"))

        # claude/mcp:
        (add-pkg-deps [pkgs.claude-code pkgs.codegraph])
        (set-env "CLAUDE_CONFIG_DIR" (noescape "~/.config/claude"))
        (mkdir-readwrite (noescape "~/.config/claude"))
        (mkdir-readwrite (noescape "~/.config/anthropic"))
        (mkdir-rw-bind (noescape "~/.local/share/codegraph") (noescape "~/.codegraph"))

        # projects:
        mount-cwd
        (mkdir-readwrite (noescape "~/projects"))
        (readwrite (noescape "~/nixos"))
        (mkdir-readwrite (noescape "~/vaults"))

        ## workflow

        (add-pkg-deps [pkgs.git pkgs.delta])
        (readonly (noescape "~/.config/git"))

        (fwd-env "EDITOR")
        (add-pkg-deps [pkgs.neovim])
        (readonly (noescape "~/.config/nvim"))
        (mkdir-readonly (noescape "~/.local/share/nvim"))
        (mkdir-readwrite (noescape "~/.local/state/nvim"))

        ## tools

        (add-pkg-deps (with pkgs; [
          curl
        ]))

        (add-pkg-deps [pkgs.kubectl])
        (set-env "KUBECONFIG" (noescape "~/.config/kube/claude.yaml"))
        (readonly (noescape "~/.config/kube/claude.yaml"))
        (fwd-env "KUBECACHEDIR")

        (fwd-env "RUSTUP_HOME")
        (fwd-env "CARGO_HOME")
        (mkdir-readwrite (noescape "~/.local/share/rustup"))
        (mkdir-readwrite (noescape "~/.local/share/cargo"))

        (mkdir-readwrite (noescape "~/.cache/uv"))
        (mkdir-readwrite (noescape "~/.local/share/uv"))
      ];
  };
}
