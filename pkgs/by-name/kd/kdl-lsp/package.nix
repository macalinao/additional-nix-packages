{
  lib,
  rustPlatform,
  fetchCrate,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "kdl-lsp";
  version = "6.7.1";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-p+8q5VBhdp/xBG71l5u8IwD7AEtFYOpHsuCvo/WkpNs=";
  };

  cargoHash = "sha256-S7IcKQR4bbJagLjkjW6A2bABNqsIxlnIEWn+PC6N0PI=";

  meta = {
    description = "LSP Server for the KDL Document Language";
    homepage = "https://github.com/kdl-org/kdl-rs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "kdl-lsp";
  };
})
