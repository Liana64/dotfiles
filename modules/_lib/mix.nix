lib: let
  channel = hex: i: lib.fromHexString (builtins.substring i 2 (lib.removePrefix "#" hex));
in
  a: b: pct: let
    part = i: lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString ((channel a i * (100 - pct) + channel b i * pct) / 100)));
  in "#${part 0}${part 2}${part 4}"
