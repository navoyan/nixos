{
  my.manageHomeForUsers = [
    "narek"
  ];

  users.users = {
    narek = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "snapper"
        "gaming-dev-tmpfs"
      ];
    };
  };
}
