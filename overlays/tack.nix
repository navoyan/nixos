/*
Unreleased git version
*/
{
  self,
  super,
  ...
}: {
  tack = super.tack.overrideAttrs {
    version = "unstable-2026-11-03";
    src = self.fetchFromGitHub {
      owner = "manic-systems";
      repo = "tack";
      rev = "aea40b8c73e6e7552229d87885fde8d1f69a060a";
      hash = "sha256-MkkhlJZhaUzGRu1XbAg2y77B9/qUZZaItZRv3e6Hinc=";
    };
    cargoHash = "sha256-vdebYO/WcRc9D5qgsTXW6z4StcB/3RkZzm43sy+RiPs=";
  };
}
