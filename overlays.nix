{ inputs, ... }:
{
  flake.overlays.default =
    final: prev:
    let
      system = prev.stdenv.hostPlatform.system;
      inputs' = builtins.mapAttrs (_: flake: flake.packages.${system}) {
        inherit (inputs) lintel mad;
      };
      allPackages = import ./packages {
        pkgs = prev;
        inherit inputs';
      };
    in
    prev.lib.filterAttrs (_: pkg: prev.lib.meta.availableOn prev.stdenv.hostPlatform pkg) allPackages;
}
