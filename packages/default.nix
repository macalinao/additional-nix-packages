{ pkgs, inputs', ... }:
{
  biome = pkgs.callPackage ./biome/package.nix { };
  devenv = inputs'.devenv.packages.devenv;
  gogcli = pkgs.callPackage ./gogcli/package.nix { };
  linear-cli = pkgs.callPackage ./linear-cli/package.nix { };
  lintel = pkgs.callPackage ./lintel/package.nix { };
  mad = pkgs.callPackage ./mad/package.nix { };
  notifykit = pkgs.callPackage ./notifykit/package.nix { };
  skhd-zig = pkgs.callPackage ./skhd-zig/package.nix { };
  wacli = pkgs.callPackage ./wacli/package.nix { };
}
