{
  lib,
  rustPlatform,
  fetchCrate,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "kdl-lsp";
  version = "6.5.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-YLoOmsQMvkzXhMLlK4e0P3nLmKxXWBXckyx0v/m3SqM=";
  };

  cargoHash = "sha256-iwc4DFsrgpVw3g1fPjFIROznVli/ooXJwKpZYwZmSOI=";

  meta = {
    description = "LSP Server for the KDL Document Language";
    homepage = "https://github.com/kdl-org/kdl-rs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "kdl-lsp";
  };
})
