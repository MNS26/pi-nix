{ inputs, lib, modulesPath, pkgs, ... }:

  let 
    edgetx-sd = pkgs.fetchzip {
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
      path = "/home/edgetx/edgetx";
      desktopName = "EdgeTX";
      genericName = "EdgeTX";
      noDisplay = false;
      terminal = true;
      comment = "Open source RC radio firmware";
      icon = "";
      keywords = [ "edge" "Edge" "edgetx" "EdgeTX" "tx" "TX" ];
    
    })
  ];
  system.activationScripts.foo = ''
    if [[ ! -e "/home/edgetx/edgetx" ]]; then
      mkdir home/edgetx/edgetx
      chown edgetx:users /home/edgetx/edgetx/
    fi
    for folder in ${edgetx-sd}/*; do
        cp -r "${edgetx-sd}/''${folder##*/}" /home/edgetx/edgetx
        chown edgetx:users -R /home/edgetx/edgetx/''${folder##*/}
    done
  '';
}