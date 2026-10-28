{nixosModules, ...}: {
  imports = with nixosModules; [
    hardware.amdgpu
    hardware.bluetooth
    hardware.airpods
    hardware.voyager
    cli.default
    desktop.default

    ./scan.nix
    ./filesystems.nix
    ./boot.nix
    ./networking.nix
    ./user.nix
  ];

  services.usbmuxd.enable = true;

  system.stateVersion = "26.05";
}
