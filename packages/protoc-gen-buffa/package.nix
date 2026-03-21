{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "protoc-gen-buffa";
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
    "protoc-gen-buffa"
  ];

  cargoTestFlags = [
    "-p"
    "protoc-gen-buffa"
  ];

  meta = {
    description = "protoc plugin for generating Rust code with buffa";
    homepage = "https://github.com/anthropics/buffa";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "protoc-gen-buffa";
  };
})
