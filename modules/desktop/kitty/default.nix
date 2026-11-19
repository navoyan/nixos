{
  pkgs,
  my,
  ...
}: let
  inherit (my.lib) symlinks;
in {
  environment.systemPackages = [pkgs.kitty];

  xdg.terminal-exec = {
    enable = true;
    settings.default = ["kitty.desktop"];
  };

  my.hjem.environment.sessionVariables = {
    TERMINAL = "kitty";
  };

  my.outOfStoreSymlinks.config.kitty = symlinks.mkSources "desktop/kitty" [
    "./kitty.conf"
    "./tokyonight.conf"
    "./tab_bar.py"
    "./move_tab.py"
  ];
}
