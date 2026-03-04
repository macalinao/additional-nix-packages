{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cargo-bundle,
  rcodesign,
  apple-sdk_15,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "notifykit";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "macalinao";
    repo = "notifykit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XIau1DU5pugslIZhSCX5MhBA+XDP1QzG5wyJtYG80d0=";
  };

  cargoHash = "sha256-2v9sStc6HKPtD5xHLgzUJDKt80RYVQ1d/O5Cn835b3A=";

  nativeBuildInputs = [
    cargo-bundle
    rcodesign
  ];

  buildInputs = [
    apple-sdk_15
  ];

  cargoBuildFlags = [
    "-p"
    "notifykit"
  ];

  postBuild = ''
    cargo bundle --release -p notifykit
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r target/release/bundle/osx/NotifyKit.app $out/Applications/
    mkdir -p $out/bin
    ln -s $out/Applications/NotifyKit.app/Contents/MacOS/notifykit $out/bin/notifykit
    runHook postInstall
  '';

  # Sign after fixup (stripping would invalidate signature if done earlier)
  postFixup = ''
    rcodesign sign $out/Applications/NotifyKit.app
  '';

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "macOS notification CLI with Claude Code hook support";
    homepage = "https://github.com/macalinao/notifykit";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    platforms = lib.platforms.darwin;
    mainProgram = "notifykit";
  };
})
