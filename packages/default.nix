{ pkgs, ... }:
{
  asimeow = pkgs.callPackage ./asimeow/package.nix { };
  biome = pkgs.callPackage ./biome/package.nix { };
  gogcli = pkgs.callPackage ./gogcli/package.nix { };
  linear-cli = pkgs.callPackage ./linear-cli/package.nix { };
  lintel = pkgs.callPackage ./lintel/package.nix { };
  mad = pkgs.callPackage ./mad/package.nix { };
  notifykit = pkgs.callPackage ./notifykit/package.nix { };
  protoc-gen-buffa = pkgs.callPackage ./protoc-gen-buffa/package.nix { };
  protoc-gen-buffa-packaging = pkgs.callPackage ./protoc-gen-buffa-packaging/package.nix { };
  protoc-gen-connect-rust = pkgs.callPackage ./protoc-gen-connect-rust/package.nix { };
  skhd-zig = pkgs.callPackage ./skhd-zig/package.nix { };
  wacli = pkgs.callPackage ./wacli/package.nix { };
}
