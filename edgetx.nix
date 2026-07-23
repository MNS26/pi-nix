{ inputs, lib, modulesPath, pkgs, ... }:

  let 
    etx-icon = pkgs.fetchurl {
      url = "https://github.com/MNS26/EdgeTX/blob/linux/radio/src/targets/linux/assets/images/icon.png";
      hash = "sha256-kNvctAQL+zc3AhUswBfOkR9idaVPitXUJzBlf5GtMXk=";
    };
    etx-path = "\\$HOME/.local/share/edge-tx/";
    etx-sd = pkgs.fetchzip {
      url = "https://github.com/EdgeTX/edgetx-sdcard/releases/download/v2.12.1/c800x480.zip";
      stripRoot=false;
      hash = "sha256-QWVvisvFwjHBDPLw7Ct0+oXYXlcDDUpk3sP0eUOKJ5Q=";
    };
  in {
  environment.systemPackages = with pkgs; [
    (inputs.edgetx.packages.${pkgs.stdenv.hostPlatform.system}.edgetx-linux.override { sd-path = etx-path; sdcard = etx-sd; })
    (makeDesktopItem {
      name = "EdgeTX";
      exec = "/run/current-system/sw/bin/edgetx";
      desktopName = "EdgeTX";
      genericName = "EdgeTX";
      noDisplay = false;
      comment = "Open source RC radio firmware";
      icon = "${etx-icon}";
      keywords = [ "edge" "Edge" "edgetx" "EdgeTX" "tx" "TX" ];
  
    })
  ];
}