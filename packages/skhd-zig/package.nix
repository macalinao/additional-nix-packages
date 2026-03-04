{
  lib,
  stdenv,
  fetchFromGitHub,
  zig_0_14,
  apple-sdk,
  rcodesign,
  replaceVars,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "skhd-zig";
  version = "0.0.17";

  src = fetchFromGitHub {
    owner = "jackielii";
    repo = "skhd.zig";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yQjWOYaavgRfcoesDlHV28sU+PBD8wL06r6BIHzrHy0=";
  };

  patches = [
    ./remove-zbench.patch
    ./headerpad.patch
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    (replaceVars ./darwin.patch {
      darwin-frameworks = "${apple-sdk.sdkroot}/System/Library/Frameworks";
      darwin-include = "${apple-sdk.sdkroot}/usr/include";
      darwin-lib = "${apple-sdk.sdkroot}/usr/lib";
    })
  ];

  nativeBuildInputs = [
    zig_0_14
    rcodesign
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk
  ];

  dontConfigure = true;
  dontInstall = true;

  buildPhase = ''
    runHook preBuild

    export ZIG_LOCAL_CACHE_DIR="$TMPDIR/zig-cache"
    export ZIG_GLOBAL_CACHE_DIR="$TMPDIR/zig-cache"

    zig build \
      -Doptimize=ReleaseFast \
      --prefix $out

    # Ad-hoc code sign for macOS accessibility permissions
    rcodesign sign $out/bin/skhd

    runHook postBuild
  '';

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
    command = "skhd --version";
    version = "v${finalAttrs.version}";
  };

  meta = {
    description = "Zig rewrite of skhd - simple hotkey daemon for macOS";
    homepage = "https://github.com/jackielii/skhd.zig";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ macalinao ];
    platforms = lib.platforms.darwin;
    mainProgram = "skhd";
  };
})
