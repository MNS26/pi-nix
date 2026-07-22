{ inputs, lib, modulesPath, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ./kde.nix
    ./edgetx.nix
#    ./visual-code-server.nix
#    ./wayfire.nix
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
#    # Desktop programs
    firefox
#
#    #audio
    #wireplumber  # redundant, included with pipewire
#
#    #fonts
    dejavu_fonts
#
#    #cli packages
    nano
    fastfetch
    btop
    curl
    evtest
    i2c-tools
    kmod
    xorg.xrandr
    wlr-randr
    pciutils
    edid-decode
#
#
#    #other
    bluez
    #console-setup
    #cpio
    #colord
    git
    squeekboard  # replaced by wvkbd in wayfire.nix

    # File manager
    nemo-with-extensions

    # Touchscreen utilities
    brightnessctl
    wlr-randr

    # GPIO (replaces gpio-utils)
    libgpiod

    # Bluetooth manager
    blueman

    # Network manager tray applet
    networkmanagerapplet

    # Power management
#    swayidle
#    wlopm
  ];
  
  environment = {
    variables = {
      SHELL = "zsh";
      EDITOR = "nano";
    };
  };

  documentation.enable = false;

  security = {
    rtkit.enable = true;
    sudo.enable = true;
  };
  users.users = {
    root = {
      initialPassword = "pi";
    };
    edgetx = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "bluetooth" ];
      initialPassword = "pi";
      openssh.authorizedKeys.keys = [
        # PC
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5JRyxENeoIQH55K6w2Ajyww/ih44jOIA7zDrGBouoy1loI0ji71gUe5jf0M75WPehcEwYEZCaVE0zcMw7iZ2P4CZq3uJhE7Y3v6Vz8WhV6pqIUM7UKN5+w06zBN8SqpfFCSAJIfc9aVH31sMqBf49ZkSxLzOvk6EHHgm//G9jAzF6Ld+CTF9MWSnX/5lPS5F0KqxXT+5mPt3Pwq7FvRKMm7A/JH2kCti8oxp5KsXm+7urs2QP5B0Q6WTNMRoeMrpyY6W8N7ahnoA5tC7C94ZBzZDnDRzodNLkN8dI8LYoYDxrOxspW6oA4ekKCj10HFtlrXpa0YRgy6kouDF16ROi8XizvM7sYvCMxtJQfnv+Xg7FSyj3t/dHs3VljtmMJxjd7wnlT1i/rVMJ6Lz1v1Caowv32fH6pG0sXmk9oTpfVpZSe2mJebl38fLGxWXj7OIuqR4EdFoScEH0TiJgAPqCI43jDfzQYgFjO8k/fdyay3F8uIvSjOxb9M4B8Ui0Khk= noah@fedora"
      ];
    };
  };

  programs = 
  {
    zsh.enable = true;
#    gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
  };

  services = {
    libinput.enable = true;
    openssh.enable = true;
    blueman.enable = true;

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
    useDHCP = lib.mkDefault true;
    hostName = "pi-nix";
#    hostId = "af1e86bc";
    firewall.enable = false;

    networkmanager.enable = false;
    #wifi config (replaced by networkmanager)
    #wireless = {
    #  enable = true;
    #  # adapters
    #  interfaces = ["wlp3s0"];
    #  #dummy network
    #  networks.Thuis = {
    #    psk = "Welkom2016!";
    #  };
    #};
  };
  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "25.11";
}