{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) getExe;

  accessGroup = "gaming-dev-tmpfs";
  mountDir = "/run/jail/gaming/dev";
in {
  systemd.mounts = [
    {
      what = "tmpfs";
      where = mountDir;
      type = "tmpfs";
      options = "mode=0755,size=1m,noexec,nosuid";
      wantedBy = ["local-fs.target"];
      before = ["systemd-udevd.service" "systemd-udev-trigger.service"];
    }
  ];

  systemd.tmpfiles.settings.dev-tmpfs = let
    dir = mode: {
      d = {
        inherit mode;
        user = "root";
        group = "root";
      };
    };
    chr = device: {
      "c+" = {
        mode = "0666";
        user = "root";
        group = "root";
        argument = device;
      };
    };
    link = target: {"L+".argument = target;};
  in {
    "${mountDir}/.stage" = dir "0700";

    "${mountDir}/dri" = dir "0755";
    "${mountDir}/input" = dir "0755";
    # mountpoint only, the jail mounts its own private tmpfs on it:
    "${mountDir}/shm" = dir "1777";

    "${mountDir}/null" = chr "1:3";
    "${mountDir}/zero" = chr "1:5";
    "${mountDir}/full" = chr "1:7";
    "${mountDir}/random" = chr "1:8";
    "${mountDir}/urandom" = chr "1:9";
    "${mountDir}/tty" = chr "5:0";

    "${mountDir}/fd" = link "/proc/self/fd";
    "${mountDir}/stdin" = link "/proc/self/fd/0";
    "${mountDir}/stdout" = link "/proc/self/fd/1";
    "${mountDir}/stderr" = link "/proc/self/fd/2";
  };

  users.groups = {
    ${accessGroup} = {};
  };

  services.udev.extraRules = let
    mirror = getExe (pkgs.writeShellApplication {
      name = "jail-gaming-dev-mirror";
      inheritPath = false;
      runtimeInputs = [pkgs.coreutils];
      text = ''
        action=$1; dir=$2; name=$3
        stage=${mountDir}/.stage
        case "$action" in
          add)
            install --directory --mode 0700 --owner root --group root "$stage"
            install --directory --mode 0755 --owner root --group root "$dir"

            rm --force -- "$stage/$name"
            mknod --mode 0660 "$stage/$name" c "$MAJOR" "$MINOR"
            chown root:${accessGroup} "$stage/$name"
            mv --force --no-target-directory -- "$stage/$name" "$dir/$name"
            ;;
          remove)
            rm --force -- "$dir/$name"
            ;;
        esac
      '';
    });
  in
    # udev
    ''
      # gpu:
      # DEVTYPE can be either "drm_minor" (real device node) or "drm_connector" (e.g. card0-HDMI-A-1)
      SUBSYSTEM=="drm", ENV{DEVTYPE}=="drm_minor", KERNEL=="renderD[0-9]*", ACTION=="add",    RUN+="${mirror} add    ${mountDir}/dri %k"
      SUBSYSTEM=="drm", ENV{DEVTYPE}=="drm_minor", KERNEL=="card[0-9]*",    ACTION=="add",    RUN+="${mirror} add    ${mountDir}/dri %k"
      SUBSYSTEM=="drm", ENV{DEVTYPE}=="drm_minor",                          ACTION=="remove", RUN+="${mirror} remove ${mountDir}/dri %k"


      # uinput:
      # NOTE: gives access to creating virtual inputs, needed for Steam Input.
      # Allows jailed process to feed device inputs into system,
      # but there seem to be no workarounds:
      SUBSYSTEM=="misc", KERNEL=="uinput", ACTION=="add",    RUN+="${mirror} add    ${mountDir} %k"
      SUBSYSTEM=="misc", KERNEL=="uinput", ACTION=="remove", RUN+="${mirror} remove ${mountDir} %k"

      # ntsync for Proton performance:
      SUBSYSTEM=="misc", KERNEL=="ntsync", ACTION=="add",    RUN+="${mirror} add    ${mountDir} %k"
      SUBSYSTEM=="misc", KERNEL=="ntsync", ACTION=="remove", RUN+="${mirror} remove ${mountDir} %k"

      # any gamepad input:
      SUBSYSTEM=="input", KERNEL=="event[0-9]*|js[0-9]*", ENV{ID_INPUT_JOYSTICK}=="1", ACTION=="add", RUN+="${mirror} add ${mountDir}/input %k"

      # any motion sensor:
      SUBSYSTEM=="input", KERNEL=="event[0-9]*", ENV{ID_INPUT_ACCELEROMETER}=="1",                      ACTION=="add", RUN+="${mirror} add ${mountDir}/input %k"
      # DualSense touchpad (<bus>:054c:0ce6:<iid>):
      SUBSYSTEM=="input", KERNEL=="event[0-9]*", ENV{ID_INPUT_TOUCHPAD}=="1", KERNELS=="*:054C:0CE6.*", ACTION=="add", RUN+="${mirror} add ${mountDir}/input %k"

      # cleanup input:
      SUBSYSTEM=="input", KERNEL=="event[0-9]*|js[0-9]*", ACTION=="remove", RUN+="${mirror} remove ${mountDir}/input %k"


      # DualSense hidraw (<bus>:054c:0ce6:<iid>):
      SUBSYSTEM=="hidraw", KERNELS=="*:054C:0CE6.*", ACTION=="add", RUN+="${mirror} add ${mountDir} %k"

      # cleanup hidraw:
      SUBSYSTEM=="hidraw", ACTION=="remove", RUN+="${mirror} remove ${mountDir} %k"
    '';
}
