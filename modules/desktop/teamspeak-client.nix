{pkgs, ...}: {
  my.jails.TeamSpeak = {
    enable = true;
    bootstrapService.enable = false;
    package = pkgs.teamspeak6-client;
    permissions = combinators:
      with combinators; [
        network
        gui
        gpu
        xdg-open
        xdg-desktop-portal
        notifications

        (mkdir-readwrite (noescape "~/.config/TeamSpeak"))
        (mkdir-readwrite (noescape "~/.cache/TeamSpeak"))

        (mkdir-readonly (noescape "~/Downloads"))
        (mkdir-readonly (noescape "~/Pictures"))
      ];
  };
}
