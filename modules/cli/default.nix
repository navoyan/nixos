{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    btop
    libqalculate

    delta
    dust
    eza
    fastfetch
    fd
    gettext
    jq
    libnotify
    moreutils
    rbw
    ripgrep
    tealdeer
    tokei
    xh

    python3
    rust-script
    rustup

    bind
    inetutils

    hydra-check
    nix-index

    gcc
    gdb

    prek
    shellcheck
  ];
}
