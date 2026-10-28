{
  virtualisation.containers = {
    enable = true;
    containersConf.settings = {
      containers.pids_limit = 20480;
    };
  };
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
}
