{ pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
#    ./visual-code-server.nix
#    ./lxqt.nix
    ];
  
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org/"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  environment.systemPackages = with pkgs; [
    wayland
    wayland-utils
    xwayland
    wlr-randr
    xdg-desktop-portal-wlr
    
    #lxqt
    lxqt.lxqt-wayland-session 
    xterm

    #lxde
    lxrandr
    lxsession
    lxpanel
    lxtask
    lxterminal

    #themes
#    lxqt.lxqt-themes
    adwaita-icon-theme
    gnome-icon-theme

    
    #wayfire
    wayfire-with-plugins
#    wayfirePlugins.wcm
    wayfirePlugins.wf-shell
#    wayfirePlugins.wwp-switcher
#    wayfirePlugins.focus-request
    wayfirePlugins.wayfire-shadows
#    wayfirePlugins.wayfire-plugins-extra

    # Desktop programs
    firefox

    #audio
    wireplumber

    #fonts
    dejavu_fonts

    #cli packages
    nano
    fastfetch
    btop
    curl
    evtest
    i2c-tools
    kmod


    #other 
    bluez
    console-setup
    cpio
    colord
#    gpio-utils
    git
    squeekboard
    # debian pi packages
    #TODO: find equivalent
#    wf-panel-pi
#    wfplug-batt
#    wfplug-bluetooth
#    wfplug-cpu
#    wfplug-cputemp
#    wfplug-gpu
#    wfplug-menu
#    wfplug-netman
#    wfplug-power
#    wfplug-squeek
#    wfplug-updater
#    wfplug-volumepulse
  ];

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };

  boot = {
    initrd = {
      availableKernelModules = [ "vc4" "v3d" ];
    };
    kernelParams = [
    "video=DSI-0:800x480@60,rotated=180"
    "console=console0,115200"
    "console=tty1,115200"
    "vt.global_cusor_default=0"
    "splat"
    "fsck.repair=yes"
    "rootwait"
    "plymouth.ignore-serial-consoles"
    "cfg80211.ieee80211_regdom=NL"
    "elevator=deadline"
    ];
  };
  documentation.enable = false;

  users.users = {
    root = {
      initialPassword = "pi";
    };
    noah = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "pi";
      openssh.authorizedKeys.keys = [
        # PC
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5JRyxENeoIQH55K6w2Ajyww/ih44jOIA7zDrGBouoy1loI0ji71gUe5jf0M75WPehcEwYEZCaVE0zcMw7iZ2P4CZq3uJhE7Y3v6Vz8WhV6pqIUM7UKN5+w06zBN8SqpfFCSAJIfc9aVH31sMqBf49ZkSxLzOvk6EHHgm//G9jAzF6Ld+CTF9MWSnX/5lPS5F0KqxXT+5mPt3Pwq7FvRKMm7A/JH2kCti8oxp5KsXm+7urs2QP5B0Q6WTNMRoeMrpyY6W8N7ahnoA5tC7C94ZBzZDnDRzodNLkN8dI8LYoYDxrOxspW6oA4ekKCj10HFtlrXpa0YRgy6kouDF16ROi8XizvM7sYvCMxtJQfnv+Xg7FSyj3t/dHs3VljtmMJxjd7wnlT1i/rVMJ6Lz1v1Caowv32fH6pG0sXmk9oTpfVpZSe2mJebl38fLGxWXj7OIuqR4EdFoScEH0TiJgAPqCI43jDfzQYgFjO8k/fdyay3F8uIvSjOxb9M4B8Ui0Khk= noah@fedora"
      ];
    };
  };

  security = {
    rtkit.enable = true;
    sudo.enable = true;
  };

  programs = 
  {
    gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
    wayfire.enable = true;
    xwayland.enable = true;
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };



  services = {
    openssh.enable = true;
    xserver = {
      enable = true;
    };

    displayManager = {
      sddm.enable = true;
      sddm.wayland.enable = true;
#      sessionPackages = with pkgs; [ lxqt.lxqt-wayland-session  ];
#      sessionPackages = with pkgs; [ wayfire-with-plugins ];
#      autoLogin = {
#        enable = true;
#        user = "noah";
#      };
    };
    desktopManager.plasma6.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
  
  hardware = {
    graphics.enable = true;
    firmware = with pkgs; [ raspberrypiWirelessFirmware ];
  };

  networking = {
    hostName = "pi-nix";
    hostId = "af1e86bc";
    firewall.enable = false;
    #wifi config
    wireless = {
      enable = true;
      # adapters
      interfaces = ["wlp3s0"];
      #dummy network
      networks.Thuis = {
        psk = "Welkom2016!";
      };
    };
  };
  
  system.stateVersion = "25.11";
}