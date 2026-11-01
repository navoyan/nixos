{
  pkgs,
  builtinCombinators,
  combinators,
  ...
}:
with combinators; {
  gui = compose [
    builtinCombinators.gui

    (add-pkg-deps [pkgs.adwaita-icon-theme])
    (readonly "/run/current-system/sw/share/icons")

    (ro-symlink-and-target (noescape "~/.local/share/icons/default/index.theme"))
  ];
}
