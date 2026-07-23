self: super: {
  edid-gen = self.callPackage ./edid {};
  generateEdid = self.callPackage ./edid/generate.nix;
}
