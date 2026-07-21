pi-nix

# VM build
nix-build '<nixpkgs/nixos>' --arg configuration ./configuration.nix -A vm

# IMG build
nix build #packages.aarch64-linux.sdImage

# Garbage collection
nix-collect-garbage --max-freed Xg