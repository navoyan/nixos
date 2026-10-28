{config, ...}: {
  programs.nh = {
    enable = true;
    flake = "${config.hj.directory}/nixos";
  };
}
