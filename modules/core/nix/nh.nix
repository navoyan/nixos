{
  programs.nh.enable = true;

  my.hjem = {config, ...}: {
    environment.sessionVariables = {
      NH_FLAKE = "${config.directory}/nixos";
    };
  };
}
