{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "protoc-gen-buffa-packaging";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "buffa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ciki7fFf5dMbSEkoCCN1CQsIthe5GEoaBzbKgE2Gaz8=";
  };

  cargoHash = "sha256-CWkSkrwFmGSjx6JRNMFrrht2gHIgx671B9FQaJcdBcI=";

  cargoBuildFlags = [
    "-p"
    "protoc-gen-buffa-packaging"
  ];

  cargoTestFlags = [
    "-p"
    "protoc-gen-buffa-packaging"
  ];

  meta = {
    description = "protoc plugin that emits a mod.rs module tree for buffa per-file output";
    homepage = "https://github.com/anthropics/buffa";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "protoc-gen-buffa-packaging";
  };
})
