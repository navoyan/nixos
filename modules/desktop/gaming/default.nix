{pkgs, ...}: {
  imports = [
    ./scripts
    ./sunshine

    ./steam.nix
  ];

  environment.systemPackages = with pkgs; [
    goverlay
    protonplus
  ];
}
