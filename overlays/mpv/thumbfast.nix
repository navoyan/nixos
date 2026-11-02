/*
Support for mpv's preview api
*/
{
  self,
  super,
  ...
}: {
  mpvScripts = super.mpvScripts.overrideScope (mself: msuper: {
    thumbfast = msuper.thumbfast.overrideAttrs {
      src = self.fetchFromGitHub {
        owner = "N-R-K";
        repo = "thumbfast";
        rev = "edbc294010bb0d7b3fc5f929c70c6f9b44132654";
        hash = "sha256-AQ28Nm+6SEELbFOa0PpCWWapcwwJ3G8ttB99QlGgeCs=";
      };
    };
  });
}
