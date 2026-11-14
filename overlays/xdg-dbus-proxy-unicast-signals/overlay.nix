/*
Let unicast signals through to unique names the client can SEE (i.e. peers that called it).
Upstream denies them unless the recipient owns a TALK-able well-known name,
so e.g. steam-runtime-launcher-service's `ProcessExited` never reaches `steam-runtime-launch-client`,
and SteamRT3 hangs on startup. Steam only avoids this when it detects Flatpak

See: https://github.com/flatpak/xdg-dbus-proxy/issues/25
*/
{prev, ...}: {
  xdg-dbus-proxy-unicast-signals = prev.xdg-dbus-proxy.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./unicast-signals.patch];
  });
}
