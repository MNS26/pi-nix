{ pkgs, config, lib, ... }:

{
  imports = [
    ./bootloader.nix
  ];
  boot = {
    initrd = {
      kernelModules = {
        netconsole = true;
      };
      availableKernelModules = {
        vc4 = true;
        v3c = true;
      };
    };
    kernelPackages = pkgs.linuxPackages_rpi4;

    kernelParams = [
    "video=DSI-1:800x480@60,rotated=180"
    "console=earlycon"
    "console=tty1,115200"
    "console=ttyS0,115200"
    "console=ttyAMA0,115200"
    "netconsole=6665@192.168.2.43/,6666@/ff:ff:ff:ff:ff:ff"
    "vc4.force_hotplug=1"
    "vt.global_cusor_default=0"
    "splat"
    "fsck.repair=yes"
    "rootwait"
    "plymouth.ignore-serial-consoles"
    "cfg80211.ieee80211_regdom=NL"
    "elevator=deadline"
    ];

    loader = {
      grub.enable = false;
    };
  };
  fileSystems = {
    "/boot/firmware" = {
      label = "bootfs";
    };
    "/" = {
      label = "rootfs";
      fsType = "ext4";
    };
  };
  hardware.enableAllHardware = lib.mkForce false;
}