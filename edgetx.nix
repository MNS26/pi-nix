{ inputs, lib, modulesPath, pkgs, ... }:

  let 
    etx-icon = pkgs.fetchurl {
      url = "https://github.com/MNS26/EdgeTX/blob/linux/radio/src/targets/linux/assets/images/icon.png";
      hash = "sha256-kNvctAQL+zc3AhUswBfOkR9idaVPitXUJzBlf5GtMXk=";
    };
    etx-path = "/home/edgetx/edgetx";
    etx-sd = pkgs.fetchzip {
      url = "https://github.com/EdgeTX/edgetx-sdcard/releases/download/v2.12.1/c800x480.zip";
      stripRoot=false;
      hash = "sha256-QWVvisvFwjHBDPLw7Ct0+oXYXlcDDUpk3sP0eUOKJ5Q=";
    };
  in {
  environment.systemPackages = with pkgs; [
    inputs.edgetx.packages.${pkgs.stdenv.hostPlatform.system}.edgetx-linux
    (makeDesktopItem {
      name = "EdgeTX";
      exec = "/run/current-system/sw/bin/edgetx";
      path = "${etx-path}";
      desktopName = "EdgeTX";
      genericName = "EdgeTX";
      noDisplay = false;
      comment = "Open source RC radio firmware";
      icon = "${etx-icon}";
      keywords = [ "edge" "Edge" "edgetx" "EdgeTX" "tx" "TX" ];
  
    })
  ];
  system.activationScripts.sd-content = ''
    if [[ ! -e "${etx-path}" ]]; then
      mkdir -p ${etx-path}
    fi
    for folder in ${etx-sd}/*; do
      cp -r "${etx-sd}/''${folder##*/}" ${etx-path}/
      echo "copied ${etx-sd}/''${folder##*/} to ${etx-path}/''${folder##*/}"
    done
    chown -R nobody:users ${etx-path}
    chmod -R 777 ${etx-path} 
  '';
}