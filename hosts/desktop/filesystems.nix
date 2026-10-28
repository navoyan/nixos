{user, ...}: {
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/33FC-1E21";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/" = {
      device = "/dev/disk/by-uuid/7cd0ba53-e929-4936-bf04-4b1e46d0375e";
      fsType = "btrfs";
      options = [
        "subvol=@"
        "compress=zstd"
      ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/7cd0ba53-e929-4936-bf04-4b1e46d0375e";
      fsType = "btrfs";
      options = [
        "subvol=@nix"
        "compress=zstd"
        "noatime"
      ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/7cd0ba53-e929-4936-bf04-4b1e46d0375e";
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "compress=zstd"
      ];
    };

    "/home/${user}/Data" = {
      device = "/dev/disk/by-uuid/a7816e36-7f97-4b49-94cb-2b85066cd571";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "subvol=@"
      ];
    };
  };
}
