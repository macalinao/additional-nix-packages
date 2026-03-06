{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lintel";
  version = "0.0.18";

  src = fetchFromGitHub {
    owner = "lintel-rs";
    repo = "lintel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tT71diY8VXvBoddEn4dCh0Qn/9MctoZWQdJBYrQas1s=";
  };

  cargoHash = "sha256-w0WjUCdu7pICjmKafHxtJY6xSTnUeLgJ5KAHk+72NRc=";

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
