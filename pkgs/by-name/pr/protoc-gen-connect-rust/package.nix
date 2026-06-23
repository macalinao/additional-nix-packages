{
  lib,
  rustPlatform,
  fetchCrate,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "protoc-gen-connect-rust";
  version = "0.7.0";

  src = fetchCrate {
    pname = "connectrpc-codegen";
    inherit (finalAttrs) version;
    hash = "sha256-1k05fZkM3Ds/PR+8+8D2JbaD1J3w2YhwI3GS6gGpkmw=";
  };

  cargoHash = "sha256-hI+fqSCdveSKMdavYd7OSt6SG3o/hFwZ6+GNEi+yBuE=";

  meta = {
    description = "Protoc plugin for generating ConnectRPC Rust service bindings";
    homepage = "https://github.com/anthropics/connect-rust";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "protoc-gen-connect-rust";
  };
})
