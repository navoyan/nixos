{
  programs.nh.enable = true;

  hj = {config, ...}: {
    environment.sessionVariables = {
      NH_FLAKE = "${config.directory}/nixos";
    };
  };
}
