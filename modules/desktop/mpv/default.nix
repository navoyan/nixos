{pkgs, ...}: let
  mpv = pkgs.mpv.override {
    scripts = with pkgs.mpvScripts; [
      mfpbar
      thumbfast
      thumbyt
      sponsorblock-minimal
    ];
  };

  detectLang = pkgs.writeShellApplication {
    name = "detect-lang";
    inheritPath = false;
    runtimeInputs = with pkgs; [
      cargo
      gcc
      rust-script
    ];
    text = ''
      exec ~/nixos/modules/desktop/mpv/detect_lang.rs "$@"
    '';
  };

  basePermissions = combinators:
    with combinators; [
      # detect-lang script:
      (add-pkg-deps [detectLang])
      (fwd-env "CARGO_HOME")
      (mkdir-readwrite (noescape "~/.local/share/cargo"))
      (mkdir-readwrite (noescape "~/.cache/rust-script"))

      # mpv dirs:
      (readonly (noescape "~/.config/mpv"))
      (mkdir-readwrite (noescape "~/.cache/mpv"))
      (mkdir-readwrite (noescape "~/.local/state/mpv"))

      # screenshots:
      (mkdir-readwrite (noescape "~/Pictures/'MPV Screenshots'"))
    ];

  permissions = combinators:
    with combinators; [
      gui
      gpu

      # yt-dlp dirs:
      (readonly (noescape "~/.config/yt-dlp"))
      (mkdir-readwrite (noescape "~/.cache/yt-dlp"))
      # browser cookies:
      (mkdir-readwrite (noescape "~/.local/share/qutebrowser"))

      # media dirs:
      (mkdir-readonly (noescape "~/Downloads"))
      (mkdir-readonly (noescape "~/Data/Videos"))
      (mkdir-readonly (noescape "~/Games"))
    ];

  permissionsWithNetwork = combinators: (permissions combinators) ++ [combinators.network];
in {
  my.jails.mpv = {
    enable = true;
    bootstrapService.enable = true;
    package = mpv;
    inherit basePermissions;
    inherit permissions;
  };

  my.jails.mpv-dl = {
    enable = true;
    bootstrapService.enable = false;
    package = mpv;
    inherit basePermissions;
    permissions = permissionsWithNetwork;
  };

  my.jails.mpv-handler = {
    enable = true;
    bootstrapService.enable = false;
    package = pkgs.mpv-handler.override {
      inherit mpv;
    };
    inherit basePermissions;
    permissions = permissionsWithNetwork;
  };

  my.outOfStoreSymlinks.config.mpv = "desktop/mpv";
}
