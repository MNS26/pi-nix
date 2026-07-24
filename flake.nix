{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    edgetx.url = "github:MNS26/EdgeTX-Nix";
  };
  outputs = { edgetx, home-manager, nixpkgs, self }@inputs:
  let
    eval = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        ./initial-setup.nix
        home-manager.nixosModules.default {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.edgetx = import ./home.nix;
          };
        }
      ];
      specialArgs.inputs = inputs;
      system = "aarch64-linux";
    };
    mkVM = system: (nixpkgs.lib.nixosSystem { 
      modules = [ 
        ./vmConfig.nix
        home-manager.nixosModules.default {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.edgetx = import ./home.nix;
          };
        }
      ]; 
      specialArgs.inputs = inputs;
      system = system;
    }).config.system.build.vm;
  in
  {
    packages = {
      x86_64-linux = {
        vm-x64 = mkVM "x86_64-linux";
        vm-aarch64 = mkVM "aarch64-linux";
        edid = nixpkgs.legacyPackages.x86_64-linux.callPackage ./edid {};
      };
#      arm7l-linux = {
#        vm-arm7l = mkVM "armv7l-linux";
#        nixos = eval.config.system.build.toplevel;
#        sdImage = eval.config.system.build.sdImage;
#        edid = nixpkgs.legacyPackages.arm7l-linux.callPackage ./edid {};
 #       inherit eval;
 #     };
      aarch64-linux = {
        vm-aarch64 = mkVM "aarch64-linux";
        nixos = eval.config.system.build.toplevel;
        sdImage = eval.config.system.build.sdImage;
        edid = nixpkgs.legacyPackages.aarch64-linux.callPackage ./edid {};
        inherit eval;
      };
    };
  };
}
