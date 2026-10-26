{pkgs, ...}: {
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

    iloader
  ];
}
