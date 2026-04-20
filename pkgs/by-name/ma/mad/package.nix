{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "mad";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "macalinao";
    repo = "mad";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vRFYw83RQMbGudKdLte2SRJ9PWZa/uwiTdFe7vxlfJo=";
  };

  cargoHash = "sha256-5HVTnukAmOpXHVZIS5IICqj7MuvJ42atODmfrTrwv24=";

  cargoBuildFlags = [
    "-p"
    "mad"
  ];

  cargoTestFlags = [
    "-p"
    "mad"
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = ''
    installShellCompletion --cmd mad \
      --bash <($out/bin/mad --bpaf-complete-style-bash) \
      --zsh <($out/bin/mad --bpaf-complete-style-zsh) \
      --fish <($out/bin/mad --bpaf-complete-style-fish)
    $out/bin/mad man > mad.1
    installManPage mad.1
  '';

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Fast Markdown terminal renderer with syntax highlighting";
    homepage = "https://github.com/macalinao/mad";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "mad";
  };
})
