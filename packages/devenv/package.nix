{
  lib,
  devenv,
  fetchFromGitHub,
  rustPlatform,
}:

let
  src = fetchFromGitHub {
    owner = "cachix";
    repo = "devenv";
    tag = "v2.0.2";
    hash = "sha256-38crLoAfEOdnEDDZD2NyAEDVlBSFn+MlZyLwztAsC8Q=";
  };
in
devenv.overrideAttrs (old: {
  version = "2.0.2";
  inherit src;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "devenv-2.0.2-vendor";
    hash = "sha256-e56HmkS+p8P/X7vS+hTT78lfQ2YDCuONM+6yW0RIfSE=";
  };

  # Fix "Exclusion ranges overlap" abort on macOS Tahoe.
  # https://github.com/cachix/devenv/issues/2553
  # The nixpkgs devenv package lists boehmgc as a direct buildInput AND
  # the nix C libraries bring in their own boehmgc from the nix_components
  # scope. Two copies of libgc.dylib get loaded, each initializing its own
  # GC and registering overlapping exclusion ranges, which aborts on Tahoe.
  # Removing the direct boehmgc dependency lets devenv get it solely through
  # the nix C libraries, ensuring only one copy is loaded.
  buildInputs = lib.filter (p: (p.pname or "") != "boehm-gc") old.buildInputs;
})
