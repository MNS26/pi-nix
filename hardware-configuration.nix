{ pkgs, config, lib, ... }:

{
  imports = [
    ./bootloader.nix
  ];
  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
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