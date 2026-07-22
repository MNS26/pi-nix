{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  ];

  environment.variables = {
    QT_IM_MODULE = "qtvirtualkeyboard";
  };
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland,x11";
    QT_QPA_PLATFORM = "wayland,x11";
    GDK_BACKEND = "wayland,x11";
  };

  services = {
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    xserver.enable = true;
  };
}
