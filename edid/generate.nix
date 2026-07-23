{ edid-gen, width, height, refresh, runCommand }:

runCommand "edid-bin" {
  nativeBuildInputs = [ edid-gen ];
} ''
  mkdir -pv $out/lib/firmware/edid
  cd $out/lib/firmware/edid
  edid-generate ${toString width} ${toString height} ${toString refresh}
''
