{
  pkgs,
  inputs',
}:
{
  biome = pkgs.callPackage ./biome/package.nix { };
  gogcli = pkgs.callPackage ./gogcli/package.nix { };
  linear-cli = pkgs.callPackage ./linear-cli/package.nix { };
  skhd-zig = pkgs.callPackage ./skhd-zig/package.nix { };
  wacli = pkgs.callPackage ./wacli/package.nix { };
  cargo-furnish = inputs'.lintel.packages.cargo-furnish;
  lintel = inputs'.lintel.packages.lintel;
  lintel-catalog-builder = inputs'.lintel.packages.lintel-catalog-builder;
  lintel-config-schema-generator = inputs'.lintel.packages.lintel-config-schema-generator;
  npm-release-binaries = inputs'.lintel.packages.npm-release-binaries;
  mad = inputs'.mad.packages.mad;
}
