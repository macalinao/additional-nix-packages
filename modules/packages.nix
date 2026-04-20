{ ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      byName = ../pkgs/by-name;
      prefixes = builtins.attrNames (builtins.readDir byName);
      collectPrefix =
        prefix:
        let
          prefixDir = byName + "/${prefix}";
          names = builtins.attrNames (builtins.readDir prefixDir);
        in
        lib.genAttrs names (name: pkgs.callPackage (prefixDir + "/${name}/package.nix") { });
      allPackages = lib.foldl' (acc: p: acc // collectPrefix p) { } prefixes;
      supportedPackages = lib.filterAttrs (
        _: pkg: lib.meta.availableOn pkgs.stdenv.hostPlatform pkg
      ) allPackages;
    in
    {
      packages = supportedPackages;
      checks = supportedPackages;
    };
}
