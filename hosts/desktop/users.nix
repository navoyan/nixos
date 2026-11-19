{
  users.users.narek = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "snapper"
      "gaming-dev-tmpfs"
    ];
  };
  hjem.users.narek = {};
}
