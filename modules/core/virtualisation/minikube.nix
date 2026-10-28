{
  imports = [
    ./podman.nix
  ];

  virtualisation.containers = {
    containersConf.settings = {
      containers.pids_limit = 20480;
    };
  };

  networking.hosts = {
    "127.0.0.1" = [
      "minikube.localhost"
      "minikube.info"
      "api.minikube.info"
      "grafana.minikube.info"
    ];
  };
}
