{
  description = "Additional Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    lintel.url = "github:lintel-rs/lintel";
    lintel.inputs.nixpkgs.follows = "nixpkgs";
    mad.url = "github:macalinao/mad";
    mad.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.flake-parts.flakeModules.easyOverlay ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem =
        {
          pkgs,
          lib,
          inputs',
          ...
        }:
        let
          allPackages = import ./packages { inherit pkgs inputs'; };
          supportedPackages = lib.filterAttrs (
            _: pkg: lib.meta.availableOn pkgs.stdenv.hostPlatform pkg
          ) allPackages;
        in
        {
          packages = supportedPackages // {
            all-supported-packages = pkgs.symlinkJoin {
              name = "all-supported-packages";
              paths = builtins.attrValues supportedPackages;
            };
          };
          overlayAttrs = supportedPackages;
        };
    };
}
