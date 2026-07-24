{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  ];

  environment.variables = {
  };
  environment.sessionVariables = {
#    XDG_SESSION_TYPE = "wayland,x11";
#    QT_QPA_PLATFORM = "wayland,x11";
#    GDK_BACKEND = "wayland,x11";
  };

  services = {
    xserver.enable = true;
    xserver.desktopManager.xfce.enable = true;
    xserver.displayManager.lightdm.enable = true;
  };
}
