{pkgs, ...}: {
  imports = [
    ./chromium
    ./discord
    ./gtk
    ./imv
    ./kitty
    ./mpv
    ./niri
    ./pipewire
    ./qt
    ./qutebrowser
    ./rofi
    ./rofi-rbw
    ./scripts
    ./spotify
    ./steam
    ./swaync
    ./waybar
    ./xdg-desktop-portal
    ./xkb
    ./yt-dlp
    ./zathura

    ./dconf.nix
    ./fonts.nix
    ./icons.nix
    ./lxqt-polkit.nix
    ./ly.nix
    ./mongodb-compass.nix
    ./pinentry.nix
    ./qbittorrent.nix
    ./telegram.nix
    ./xdg-open.nix
  ];

  environment.systemPackages = with pkgs; [
    wl-clipboard

    hyprpicker
    xwininfo

    awww
    cliphist
    swayidle

    drawy
    libreoffice
    obs-studio

    gammaray
    gparted
    iloader
  ];
}
