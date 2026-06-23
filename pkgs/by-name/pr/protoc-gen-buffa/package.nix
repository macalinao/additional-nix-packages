{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "protoc-gen-buffa";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "buffa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Qxgv6GUp1UoAKDfEqrhGpk4HTn9jtLOOeh4U8Ws63oI=";
  };

  cargoHash = "sha256-nXjW6Dr+S0HhAf7LD24UZPjU9puae+qRBeuk1c7Rdkk=";

  cargoBuildFlags = [
    "-p"
    "protoc-gen-buffa"
  ];

  cargoTestFlags = [
    "-p"
    "protoc-gen-buffa"
  ];

  meta = {
    description = "Protoc plugin for generating Rust code with buffa";
    homepage = "https://github.com/anthropics/buffa";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "protoc-gen-buffa";
  };
})
