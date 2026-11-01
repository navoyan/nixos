{
  my.jails.mongodb-compass = {
    enable = true;
    bootstrapService.enable = true;
    permissions = combinators:
      with combinators; [
        network
        gtk
        gpu
        xdg-desktop-portal
        secrets

        (wrap-entry (entry: ''
          ${entry} --ignore-additional-command-line-flags --password-store="gnome-libsecret"
        ''))

        (mkdir-readwrite (noescape "~/.config/'MongoDB Compass'"))
        (mkdir-rw-bind (noescape "~/.local/state/mongodb-compass") (noescape "~/.mongodb/compass"))

        (mkdir-readonly (noescape "~/Downloads"))
        (mkdir-readonly (noescape "~/projects"))
      ];
  };
}
