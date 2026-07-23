{ stdenv }:

stdenv.mkDerivation {
  name = "edid";
  src = ./.;
  meta.mainProgram = "edid-generate";
}
