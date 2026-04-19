{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "protoc-gen-connect-rust";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "connect-rust";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Hwsso0i5TM7tbtxMiDOuCMRVp68zVUEFXCRymaNCWbI=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoBuildFlags = [
    "-p"
    "connectrpc-codegen"
  ];

  cargoTestFlags = [
    "-p"
    "connectrpc-codegen"
  ];

  meta = {
    description = "Protoc plugin for generating ConnectRPC Rust service bindings";
    homepage = "https://github.com/anthropics/connect-rust";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "protoc-gen-connect-rust";
  };
})
