{pkgs, ...}: {
  imports = [
    ./bluetooth.nix
  ];

  programs.librepods.enable = true;

  environment.systemPackages = with pkgs; [
    alsa-utils
  ];
}
