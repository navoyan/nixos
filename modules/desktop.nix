{
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.apple-emoji-nix.overlays.default
  ];

  fonts = {
    packages = with pkgs; [
      noto-fonts
      nerd-fonts.jetbrains-mono
      apple-emoji-nix
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Noto Serif"];
        sansSerif = ["Noto Sans"];
        emoji = ["Apple Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font"];
      };
    };
  };
}
