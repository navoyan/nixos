{pkgs, ...}: {
  imports = [
    ./bat
    ./direnv
    ./fish
    ./git
    ./k9s
    ./lazygit
    ./less
    ./npage
    ./nvim
    ./scripts
    ./wiremix
    ./yazi

    ./claude.nix
    ./fzf.nix
    ./zoxide.nix
  ];

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
