{ lib, inputs, modulesPath, pkgs, ... }:
let
  edid-bin = pkgs.generateEdid {
    width = 800;
    height = 480;
    refresh = 60;
  };
in {
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ./configuration.nix
    ./initial-setup.nix
  ];

  boot = {
    initrd = {
      allowMissingModules = true;
      availableKernelModules = {
        vc4 = lib.mkForce false;
        v3c = lib.mkForce false;
      };
      extraFirmwarePaths = [ "edid/test.bin" ];
    };
    kernelPackages = lib.mkVMOverride pkgs.linuxPackages;
    kernelParams = [
      "video=Virtual-1=800x480@60"
      #"drm.edid_firmware=Virtual-1:edid/test.bin"
    ];
    plymouth.enable = lib.mkVMOverride false;
  };
  environment.variables = {QT_IM_MODULE = lib.mkVMOverride "";};
  environment.sessionVariables = lib.mkVMOverride {WLR_RENDERER_ALLOW_SOFTWARE = "1";};
  hardware.firmware = [ edid-bin ];
  nixpkgs.overlays = [ (import ./overlay.nix) ];
  security.sudo = lib.mkVMOverride {
    enable = true;
    wheelNeedsPassword = false;
  };
  virtualisation = {
    cores = 4;
    diskImage = null;
    memorySize = 1024*8;
    qemu = {
      options = [
        "--nodefaults"
        "-serial mon:stdio"
      ] ++ lib.optional (pkgs.stdenv.hostPlatform.isx86_64) "-vga virtio" # not that this should be built on arm though . . .
      ;
      #ovmf = {
        #enable = true;
        #packages = [ pkgs.OMVFFull.fd ];
      #};
      package = (import pkgs.path { system = "x86_64-linux"; }).qemu;
    };
    useEFIBoot = pkgs.stdenv.hostPlatform.isx86_64;
    resolution = {
      x = 800;
      y = 480;
    };
  };
}
