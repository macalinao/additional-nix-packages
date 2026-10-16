{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;
  strictDeps = true;

  pname = "finicky";
  version = "4.2.2";

  # Upstream's signed, notarized universal build. Building from source needs
  # Xcode (the app shell is Swift/Objective-C with a Go core and a Svelte UI).
  src = fetchurl {
    url = "https://github.com/johnste/finicky/releases/download/v${finalAttrs.version}/Finicky.dmg";
    hash = "sha256-XwAgeCyQddJ0EdYIPXvoZjiR4xRshur60RjESswSII8=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = "Finicky.app";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications/Finicky.app"
    cp -R . "$out/Applications/Finicky.app"
    runHook postInstall
  '';

  # Leave the bundle byte-for-byte as shipped: stripping or patching would
  # break the code signature.
  dontFixup = true;

  meta = {
    description = "macOS app for always opening the right browser";
    homepage = "https://github.com/johnste/finicky";
    changelog = "https://github.com/johnste/finicky/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.platforms.darwin;
    mainProgram = "Finicky";
  };
})
