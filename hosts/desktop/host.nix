{my, ...}: {
  imports = with my.modulePresets; [
    hardware.airpods
    hardware.amdgpu
    hardware.bluetooth
    hardware.dualsense
    hardware.voyager
    core.podman
    core.minikube
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
