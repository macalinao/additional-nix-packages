{
  lib,
  stdenv,
  fetchFromGitHub,
  zig_0_16,
  apple-sdk,
  rcodesign,
  replaceVars,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;
  strictDeps = true;

  pname = "skhd-zig";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "jackielii";
    repo = "skhd.zig";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Qi5srrpdhf3VcXaqZbijJD23Um0G7WgRzK0hR+mb7nU=";
  };

  patches = [
    ./remove-zbench.patch
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # build.zig pins an explicit macOS deployment target, which makes Zig
    # stop auto-resolving the SDK, so upstream probes `xcrun` for it. Point
    # it at the nixpkgs SDK instead.
    (replaceVars ./darwin.patch {
      darwin-sdkroot = "${apple-sdk.sdkroot}";
    })
  ];

  nativeBuildInputs = [
    zig_0_16
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
    rcodesign sign $out/bin/skhd-grabber

    runHook postBuild
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Zig rewrite of skhd - simple hotkey daemon for macOS";
    homepage = "https://github.com/jackielii/skhd.zig";
    changelog = "https://github.com/jackielii/skhd.zig/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ macalinao ];
    platforms = lib.platforms.darwin;
    mainProgram = "skhd";
  };
})
