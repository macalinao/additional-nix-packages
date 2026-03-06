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
})
