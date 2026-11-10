/*
Use plain (square) borders instead of rounded ones across the TUI.
*/
{prev, ...}: {
  sofka = prev.sofka.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      +
      # bash
      ''
        substituteInPlace $(grep -rl --include='*.rs' 'BorderType::Rounded' src) \
          --replace-fail 'BorderType::Rounded' 'BorderType::Plain'
      '';
  });
}
