{
  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "true";
      Domains = ["~."];
      DNSOverTLS = "true";
      FallbackDNS = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };
  };
}
