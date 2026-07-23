{pkgs, ... }:
let
  localUdevRules = pkgs.runCommand "copy-udev-rules" {} ''
    mkdir -p $out/lib/udev/rules.d
    cp ${./udev-rules}/* $out/lib/udev/rules.d/
  '';
in {
  services.udev.packages = [ localUdevRules ];
}