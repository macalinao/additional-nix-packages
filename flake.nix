{
  description = "Additional Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      imports = [ ./overlays.nix ];

      perSystem =
        {
          pkgs,
          lib,
          ...
        }:
        let
          allPackages = import ./packages { inherit pkgs; };
          supportedPackages = lib.filterAttrs (
            _: pkg: lib.meta.availableOn pkgs.stdenv.hostPlatform pkg
          ) allPackages;
        in
        {
          packages = supportedPackages;
          checks = supportedPackages;
        };
    };
}
