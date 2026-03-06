{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lintel";
  version = "0.0.19";

  src = fetchFromGitHub {
    owner = "lintel-rs";
    repo = "lintel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oM7JrzlVYf5StHeeaWo9NJlI8EFLs3qLBxlYAHGH+kg=";
  };

  cargoHash = "sha256-iq3gf2n5cAXmPxSFuB517Oum8CdrRgDcqGct84Nfutg=";

  cargoBuildFlags = [
    "-p"
    "lintel"
  ];

  cargoTestFlags = [
    "-p"
    "lintel"
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = ''
    installShellCompletion --cmd lintel \
      --bash <($out/bin/lintel --bpaf-complete-style-bash) \
      --zsh <($out/bin/lintel --bpaf-complete-style-zsh) \
      --fish <($out/bin/lintel --bpaf-complete-style-fish)
    $out/bin/lintel man > lintel.1
    installManPage lintel.1
  '';

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Fast JSON Schema linter for JSON and YAML config files";
    homepage = "https://github.com/lintel-rs/lintel";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "lintel";
  };
})
