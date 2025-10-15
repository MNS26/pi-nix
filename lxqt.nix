{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kdePackages.breeze-icons
    killall
    lxqt.lxqt-session
    lxqt.lxqt-wayland-session
    swaylock
    # LXQt uses this for it's terminal in some cases
    xterm
  ] ++ pkgs.lxqt.preRequisitePackages
    ++ pkgs.lxqt.corePackages;

  environment.etc."lxqt/session.conf".text = ''
    [General]
    leave_confirmation=true
    compositor=wayfire
    lock_command_wayland=swaylock
  '';

  # Link some extra directories in /run/current-system/software/share
  environment.pathsToLink = [ "/share" "${pkgs.lxqt.lxqt-wayland-session}/share" ];

  systemd.tmpfiles.rules = [
    "L+ /home/vali/.config/lxqt/session.conf - - - - /etc/lxqt/session.conf"
  ];

  programs = {
    gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
    wayfire = {
      enable = true;
      plugins = with pkgs.wayfirePlugins; [
        wcm
        wf-shell
        wayfire-plugins-extra
      ];
    };
    xwayland.enable = true;
  };

  security = {
    pam.services.swaylock = { };
    polkit.enable = true;
  };

  services = {
    displayManager = {
      # Set what the greeter defaults to
      defaultSession = "lxqt-wayland";
      sessionPackages = [ pkgs.lxqt.lxqt-wayland-session ];
    };
    # Virtual file systems support for PCManFM-QT
    gvfs.enable = true;
    # Enable libinput
    libinput.enable = true;
    # Window manager only sessions (unlike DEs) don't handle XDG
    # autostart files, so force them to run the service
    xserver.desktopManager.runXdgAutostartIfNone = true;
  };

  xdg.portal.lxqt.enable = true;
  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1050804
  xdg.portal.config.lxqt.default = [
    "lxqt"
    "gtk"
  ];
}