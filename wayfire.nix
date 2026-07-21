{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (wayfire-with-plugins.override { plugins = with pkgs.wayfirePlugins; [
        wcm
        wf-shell
        wayfire-plugins-extra
      ];
    })
    wf-config

    # Panel
    waybar

    # On-screen keyboard
    wvkbd

    # App launchers
    wofi
    #rofi-wayland

    # Notifications
    #dunst
    #mako
  ];

  environment.variables = {
    QT_IM_MODULE = "qtvirtualkeyboard";
  };
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland,x11";
    QT_QPA_PLATFORM = "wayland,x11";
    GDK_BACKEND = "wayland,x11";
  };

  programs = {
    wayfire = {
      enable = true;
      xwayland.enable = true;
    };
    foot.enable = true;
  };

  services = {
    xserver = {
      enable = true;
    };

    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;

    # Notifications
    #dunst.enable = true;
    #mako.enable = true;
  };
}
