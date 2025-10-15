{
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  outputs = { self, nixpkgs, vscode-server }: {
    nixosConfigurations.pi = nixpkgs.lib.nixosSystem {
      modules = [ 
        vscode-server.nixosModule.default 
        ({ config, pkgs, ...}: {
          services.vscode-server.enable = true;
        })
      ];
    };
  };
}