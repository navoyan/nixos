/*
Support for mpv's preview api
*/
{
  final,
  prev,
  ...
}: {
  mpvScripts = prev.mpvScripts.overrideScope (mfinal: mprev: {
    thumbfast = mprev.thumbfast.overrideAttrs {
      src = final.fetchFromGitHub {
        owner = "N-R-K";
        repo = "thumbfast";
        rev = "edbc294010bb0d7b3fc5f929c70c6f9b44132654";
        hash = "sha256-AQ28Nm+6SEELbFOa0PpCWWapcwwJ3G8ttB99QlGgeCs=";
      };
    };
  });
}
