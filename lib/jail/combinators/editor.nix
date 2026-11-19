{
  pkgs,
  combinators,
  ...
}:
with combinators; {
  editor = compose [
    (add-pkg-deps (with pkgs; [git delta]))
    (readonly (noescape "~/.config/git"))

    (add-pkg-deps [pkgs.neovim])
    (set-env "EDITOR" "nvim")
    (readonly (noescape "~/.config/nvim"))
    (mkdir-readonly (noescape "~/.local/share/nvim"))
    (mkdir-readwrite (noescape "~/.local/state/nvim"))
    (mkdir-readwrite (noescape "~/vaults"))
  ];
}
