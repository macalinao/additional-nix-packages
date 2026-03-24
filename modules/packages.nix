{ ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      allPackages = import ../packages { inherit pkgs; };
      supportedPackages = lib.filterAttrs (
        _: pkg: lib.meta.availableOn pkgs.stdenv.hostPlatform pkg
      ) allPackages;
    in
    {
      packages = supportedPackages;
      checks = supportedPackages;
    };
}
