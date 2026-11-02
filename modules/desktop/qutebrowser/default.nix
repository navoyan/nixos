{
  pkgs,
  flake,
  localLib,
  ...
}: let
  thirdPartyScripts = {
    ytAdsBypass = pkgs.fetchurl {
      url = "https://update.greasyfork.org/scripts/575941/1836031/YouTube%20Ads-Bypass.user.js";
      hash = "sha256-SdANPGG210MgZo6FZO0REUuzA6rBTHGbuQ7s8wEHUDA=";
    };
    ytShortsBlocker = pkgs.fetchurl {
      url = "https://update.greasyfork.org/scripts/471062/1621848/YouTube%20Shorts%20Blocker.user.js";
      hash = "sha256-OLJVeAi2qLwWtaHTExbjxKbREGN3O/mTT7jdsgHuWcQ=";
    };
  };
in {
  nixpkgs.overlays = [flake.overlays.qutebrowser];

  my.jails.qutebrowser = {
    enable = true;
    bootstrapService.enable = true;
    package = pkgs.qutebrowser.override {
      withPdfReader = false;
    };
    permissions = combinators:
      with combinators; [
        network
        qt
        gpu
        xdg-open
        xdg-desktop-portal
        notifications

        (add-pkg-deps [
          thirdPartyScripts.ytAdsBypass
          thirdPartyScripts.ytShortsBlocker
        ])

        (dbus {
          own = [
            "org.mpris.MediaPlayer2.chromium.*"
            "org.mpris.MediaPlayer2.qutebrowser.*"
          ];
        })

        (mkdir-readwrite (noescape "~/.config/qutebrowser"))
        (mkdir-readwrite (noescape "~/.cache/qutebrowser"))
        (mkdir-readwrite (noescape "~/.local/share/qutebrowser"))

        (mkdir-readwrite (noescape "~/Downloads"))
        (mkdir-readwrite (noescape "~/Documents"))
        (mkdir-readwrite (noescape "~/Pictures"))

        ## integrations:

        # mpv:
        (jail-to-host-channel "mpv"
          # bash
          ''
            mime=$(handlr mime "$1" --json | jq -r '.[0].mime')
            if [[ "$mime" =~ ^x-scheme-handler/http(s)?$ ]]; then
              mpv-dl "$1"
            fi
          '')

        # kitty:
        (add-pkg-deps [pkgs.kitty])
        (readonly (noescape "~/.config/kitty"))
        (mkdir-readwrite (noescape "~/.cache/kitty"))

        # nvim:
        (add-pkg-deps [pkgs.neovim pkgs.git])
        (readonly (noescape "~/.config/nvim"))
        (mkdir-readwrite (noescape "~/.cache/nvim"))
        (mkdir-readonly (noescape "~/.local/share/nvim"))
        (mkdir-readonly (noescape "~/vaults"))

        # yazi:
        (add-pkg-deps [pkgs.yazi])
        (readonly (noescape "~/.config/yazi"))
        (mkdir-readwrite (noescape "~/.cache/yazi"))
      ];
  };

  my.outOfStoreSymlinks.config.qutebrowser = localLib.symlinks.mkSources "desktop/qutebrowser" [
    "./config.py"
    "./tokyonight.py"
    "./jseval"
    "./content.css"
    "./greasemonkey"
  ];

  hj.xdg.data.files = {
    "qutebrowser/greasemonkey/yt_ads_bypass.js".source = thirdPartyScripts.ytAdsBypass;
    "qutebrowser/greasemonkey/yt_shorts_blocker.js".source = thirdPartyScripts.ytShortsBlocker;
  };

  hj.xdg.mime-apps = {
    added-associations = {
      "x-scheme-handler/chrome" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/mailto" = "org.qutebrowser.qutebrowser.desktop";
    };
    default-applications = {
      "application/x-extension-html" = "org.qutebrowser.qutebrowser.desktop";
      "application/x-extension-htm" = "org.qutebrowser.qutebrowser.desktop";
      "application/x-extension-shtml" = "org.qutebrowser.qutebrowser.desktop";
      "application/x-extension-xhtml" = "org.qutebrowser.qutebrowser.desktop";
      "application/x-extension-xht" = "org.qutebrowser.qutebrowser.desktop";
      "application/xhtml+xml" = "org.qutebrowser.qutebrowser.desktop";
      "text/html" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/about" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/chrome" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/mailto" = "org.qutebrowser.qutebrowser.desktop";
    };
  };
}
