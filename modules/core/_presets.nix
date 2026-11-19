{
  default = [
    ./hjem
    ./nix

    ./boot.nix
    ./compatibility.nix
    ./jails.nix
    ./locale.nix
    ./networking.nix
    ./security.nix
    ./snapper.nix
    ./tack.nix
    ./xdg.nix
  ];
  podman = [./virtualisation/podman.nix];
  minikube = [./virtualisation/minikube.nix];
}
