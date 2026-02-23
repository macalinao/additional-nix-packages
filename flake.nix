{
  description = "Additional Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    lintel.url = "github:lintel-rs/lintel";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      lintel,
    }:
    {
      overlays.default =
        final: prev:
        let
          zbench-zig = final.callPackage ./packages/zbench-zig/package.nix { };
        in
        {
          biome = final.callPackage ./packages/biome/package.nix { };
          gogcli = final.callPackage ./packages/gogcli/package.nix { };
          linear-cli = final.callPackage ./packages/linear-cli/package.nix { };
          skhd-zig = final.callPackage ./packages/skhd-zig/package.nix { inherit zbench-zig; };
          wacli = final.callPackage ./packages/wacli/package.nix { };
        }
        // builtins.removeAttrs (lintel.packages.${prev.stdenv.hostPlatform.system} or { }) [
          "all"
          "default"
        ];
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zbench-zig = pkgs.callPackage ./packages/zbench-zig/package.nix { };
        lintelPackages = builtins.removeAttrs (lintel.packages.${system} or { }) [
          "all"
          "default"
        ];
        packages = {
          biome = pkgs.callPackage ./packages/biome/package.nix { };
          gogcli = pkgs.callPackage ./packages/gogcli/package.nix { };
          linear-cli = pkgs.callPackage ./packages/linear-cli/package.nix { };
          skhd-zig = pkgs.callPackage ./packages/skhd-zig/package.nix { inherit zbench-zig; };
          wacli = pkgs.callPackage ./packages/wacli/package.nix { };
        }
        // lintelPackages;
      in
      let
        lib = pkgs.lib;
        supportedPackages = lib.filterAttrs (
          _: pkg: lib.meta.availableOn pkgs.stdenv.hostPlatform pkg
        ) packages;
        allPkg = pkgs.symlinkJoin {
          name = "all-packages";
          paths = builtins.attrValues supportedPackages;
        };
      in
      {
        packages = packages // {
          all = allPkg;
          default = allPkg;
        };
      }
    );
}
