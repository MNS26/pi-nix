{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  environment.systemPackages = with pkgs; [
    wayland
    xwayland
    wlr-randr
    xdg-desktop-portal-wlr
    
    #lxde
    lxrandr
    lxsession
    lxpanel
    lxtask
    lxterminal
    

    # plasma
#    rPackages.plasma
    
    #wayfire
    wayfire
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
    QT_QPA_PLATFORM = "wayland,xcb";
    GDK_BACKEND = "wayland,x11";
    NIXOS_OZONE_WL = "1";
  };

  boot = {
    initrd = {
#      availableKernelModules = [ "vc4" "v3d" ];
    };
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

  services = {
    openssh.enable = true;

    xserver.displayManager.lightdm.enable = false;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
  
  programs = {
    wayfire.enable = true;
    xwayland.enable = true;
  };

  hardware = {
#    graphics.enable = true;
    firmware = [ pkgs.raspberrypiWirelessFirmware ];
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
    };
  };
  
  system.stateVersion = "25.11";
}