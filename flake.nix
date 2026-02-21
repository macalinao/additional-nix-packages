{
  description = "Additional Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    {
      overlays.default = final: prev: {
        gogcli = final.callPackage ./packages/gogcli { };
        wacli = final.callPackage ./packages/wacli { };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = {
          gogcli = pkgs.callPackage ./packages/gogcli { };
          wacli = pkgs.callPackage ./packages/wacli { };
        };
      in
      {
        packages = packages // {
          all = pkgs.symlinkJoin {
            name = "all-packages";
            paths = builtins.attrValues packages;
          };
          default = self.packages.${system}.all;
        };
      }
    );
}
