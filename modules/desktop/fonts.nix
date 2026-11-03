{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      noto-fonts
      nerd-fonts.jetbrains-mono
      apple-color-emoji
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
