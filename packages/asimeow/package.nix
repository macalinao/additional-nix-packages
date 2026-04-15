{
  lib,
  rustPlatform,
  fetchFromGitHub,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "asimeow";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "mdnmdn";
    repo = "asimeow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NKUWoBpR1Af0qc7CTIQ8D3zdxSNdTM/pCou/dQSg+Js=";
  };

  cargoHash = "sha256-wjIDv+fWYdqpKC0lC99B1BIkQ1DvhLhsadlQhFG+83M=";

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
    command = "asimeow version";
    version = "Asimeow version ${finalAttrs.version}";
  };

  meta = {
    description = "Smart command line macOS Time Machine exclusion manager for busy developers";
    homepage = "https://github.com/mdnmdn/asimeow";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "asimeow";
    platforms = lib.platforms.darwin;
  };
})
