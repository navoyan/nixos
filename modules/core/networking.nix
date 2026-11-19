{lib, ...}: let
  inherit (lib.modules) mkForce;
in {
  networking.networkmanager = {
    enable = true;
    dns = mkForce "none";
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  networking.nameservers = [
    "9.9.9.9"
    "149.112.112.112"
  ];

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "true";
      Domains = ["~."];
      DNSOverTLS = "true";
      FallbackDNS = [
        "9.9.9.9"
        "149.112.112.112"
      ];
    };
  };
}
