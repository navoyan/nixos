{
  pkgs,
  flake,
  ...
}: {
  nixpkgs.overlays = [flake.overlays.sofka];

  my.jails.sofka = {
    enable = true;
    bootstrapService.enable = false;
    permissions = combinators:
      with combinators; [
        network
        xdg-open

        (readonly (noescape "~/.config/sofka"))
        (mkdir-readwrite (noescape "~/.cache/sofka"))
        (mkdir-readwrite (noescape "~/.local/state/sofka"))

        ## implicit dependencies
        (add-pkg-deps (with pkgs; [
          kubectl
          kubelogin-oidc
          kubernetes-helm
        ]))
        (fwd-env-path readonly "KUBECONFIG")
        (fwd-env-path mkdir-readwrite "KUBECACHEDIR")

        ## editor
        editor
        (add-pkg-deps [pkgs.yaml-language-server])
      ];
  };

  my.outOfStoreSymlinks.config.sofka = "cli/sofka";
}
