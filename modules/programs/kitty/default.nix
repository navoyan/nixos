{
  pkgs,
  localLib,
  ...
}: {
  environment.systemPackages = [pkgs.kitty];

  xdg.terminal-exec = {
    enable = true;
    settings.default = ["kitty.desktop"];
  };

  hj.environment.sessionVariables = {
    TERMINAL = "kitty";
  };

  my.outOfStoreSymlinks.config.kitty = localLib.symlinks.mkSources "programs/kitty" [
    "./kitty.conf"
    "./tokyonight.conf"
    "./tab_bar.py"
    "./move_tab.py"
  ];
}
