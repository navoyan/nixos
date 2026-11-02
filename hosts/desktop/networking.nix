{pkgs, ...}: {
  networking = {
    wireless.enable = true;
    firewall.allowedTCPPorts = [8900 8901 8902];
  };

  services.netbird = {
    enable = true;
    ui.enable = false;
  };

  environment.systemPackages = with pkgs; [
    proton-vpn-cli
  ];
}
