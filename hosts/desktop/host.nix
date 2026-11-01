{modulePresets, ...}: {
  imports = with modulePresets; [
    hardware.amdgpu
    hardware.bluetooth
    hardware.airpods
    hardware.voyager
    cli.default
    desktop.default
    desktop.gaming

    ./scan.nix
    ./filesystems.nix
    ./boot.nix
    ./networking.nix
    ./users.nix
  ];

  services.usbmuxd.enable = true;

  system.stateVersion = "26.05";
}
