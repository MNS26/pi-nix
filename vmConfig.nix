{ lib, inputs, modulesPath, pkgs, ... }: 
let
  edid = pkgs.callPackage ./edid {};
  edid-bin = pkgs.runCommand "edid-bin" {buildInputs = [ edid ]; compressFirmware = false;} ''
    mkdir -pv $out/lib/firmware/edid
    cd $out/lib/firmware/edid
    edid-generate 800 480 60
  '';
in {
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ./configuration.nix
    ./initial-setup.nix
  ];

  hardware.firmware = [ edid-bin ];
  boot.initrd = {
    availableKernelModules = {
      vc4 = lib.mkForce false;
      v3c = lib.mkForce false;
    };
  };
  boot.plymouth.enable = lib.mkVMOverride false;
  boot.initrd.extraFirmwarePaths = [ "edid/test.bin" ];
  boot.initrd.allowMissingModules = true;
  boot.kernelPackages = lib.mkVMOverride pkgs.linuxPackages;
  boot.kernelParams = [ 
    "video=Virtual-1=800x480@60"
  #  "drm.edid_firmware=Virtual-1:edid/test.bin"
  ];
  environment.sessionVariables = lib.mkVMOverride {WLR_RENDERER_ALLOW_SOFTWARE = "1";};
  security.sudo = lib.mkVMOverride {
    enable = true;
    wheelNeedsPassword = false;
  };
  virtualisation = {
    cores = 4;
    memorySize = 1024*8;
    qemu.options = [
      (if pkgs.stdenv.hostPlatform.isAarch64 then "-device virtio-gpu-pci" else "-vga virtio") # not that this should be built on arm though . . . 
      "-serial mon:stdio"
    ];
#    qemu.ovmf = {
#      enable = true;
#      packages = [ pkgs.OMVFFull.fd ];
#    };
    useEFIBoot = true;
    resolution = {
        x = 800;
        y = 480;
      };
  };
}