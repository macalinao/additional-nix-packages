{
  lib,
  rustPlatform,
  fetchFromGitHub,
  apple-sdk_15,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "rift";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "rift";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oOVNq4/hdiRcCbc9kaMxynnq2gXVezviQRTvjrdkfPs=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "continue-0.1.1" = "sha256-8S+gPfz6CtzIKsGh9wg3CevMdNA9V+KOyHR9F9DlVcw=";
      "dispatchr-1.0.0" = "sha256-Df6PdDA5bpmy2P30vGdad+EiHJiANmHrRF2q75Uegik=";
    };
  };

  buildInputs = [
    apple-sdk_15
  ];

  # rift links against macOS private frameworks (SkyLight, MultitouchSupport,
  # Carbon, IOKit, …) that live in the dyld shared cache, not the public SDK.
  cargoBuildFlags = [
    "--bin"
    "rift"
  ];

  # The `dev` helper binary is not meant for distribution.
  cargoTestFlags = [
    "--bin"
    "rift"
  ];

  # rift has no --version flag and running it bare launches the window manager
  # (which needs Accessibility permission), so smoke-test the CLI via --help.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/rift --help
    runHook postInstallCheck
  '';

  meta = {
    description = "Tiling window manager for macOS focused on performance and usability";
    homepage = "https://github.com/acsandmann/rift";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "rift";
    platforms = lib.platforms.darwin;
  };
})
