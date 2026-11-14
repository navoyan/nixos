{pkgs, ...}: {
  services.vds.enable = true;

  environment.systemPackages = [pkgs.dualsensectl];
}
