/*
JetBrains Mono Nerd Font with the `***` ligature disabled.

See:
- https://github.com/navoyan/JetBrainsMono/commit/5f501285155e1e5950af99c7546533d305bf6406
- https://github.com/navoyan/nerd-fonts/commit/fc021963062b402f0a71d25e26c13541a4b2d8cc
*/
{
  final,
  prev,
  ...
}: {
  nerd-fonts =
    prev.nerd-fonts
    // {
      jetbrains-mono = prev.nerd-fonts.jetbrains-mono.overrideAttrs (finalAttrs: _: {
        src = final.fetchgit {
          url = "https://github.com/navoyan/nerd-fonts";
          rev = "fc021963062b402f0a71d25e26c13541a4b2d8cc";
          sparseCheckout = ["patched-fonts/JetBrainsMono/Ligatures"];
          hash = "sha256-++whiEkFjzfTd4/+MLQpZ8IMsnCkwxe57u/ML+84Ekc=";
        };
        sourceRoot = "${finalAttrs.src.name}/patched-fonts/JetBrainsMono/Ligatures";
      });
    };
}
