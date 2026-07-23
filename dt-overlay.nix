{ pkgs, lib, kernel }:

let
  overlayDir = ./dt-overlays;

  dtsFiles = lib.filterAttrs
    (name: _: lib.hasSuffix ".dts" name)
    (builtins.readDir overlayDir);

  compileOverlay = name:
    pkgs.deviceTree.compileDTS {
      name = lib.removeSuffix ".dts" name;
      dtsFile = overlayDir + "/${name}";
      includePaths = [
        "${lib.getDev kernel}/lib/modules/${kernel.modDirVersion}/source/scripts/dtc/include-prefixes"
      ];
    };

  compiled = lib.mapAttrs' (name: _: {
    name = lib.removeSuffix ".dts" name;
    value = compileOverlay name;
  }) dtsFiles;

  dtoverlayLines = map (name: "dtoverlay=${name}") (builtins.attrNames compiled);

  overlayDirDrv = pkgs.runCommand "dt-overlays" {} ''
    mkdir -p $out
    ${lib.concatStringsSep "\n" (map (name: "cp -v ${compiled.${name}} $out/${name}.dtbo") (builtins.attrNames compiled))}
  '';

in {
  overlays = compiled;
  inherit dtoverlayLines overlayDirDrv;
}
