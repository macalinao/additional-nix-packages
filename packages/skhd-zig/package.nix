{
  lib,
  stdenv,
  fetchFromGitHub,
  zig_0_14,
  apple-sdk,
  rcodesign,
  replaceVars,
  zbench-zig,
}:

let
  version = "0.0.17";
in

stdenv.mkDerivation {
  pname = "skhd-zig";
  inherit version;

  src = fetchFromGitHub {
    owner = "jackielii";
    repo = "skhd.zig";
    rev = "v${version}";
    hash = "sha256-yQjWOYaavgRfcoesDlHV28sU+PBD8wL06r6BIHzrHy0=";
  };

  patches = lib.optionals stdenv.hostPlatform.isDarwin [
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

    # Provide zbench dependency via --system
    mkdir -p "$TMPDIR/deps/zbench-0.10.0-YTdc7-cmAQCnYOFNUAy3wZ-Sx9-_r8lW4uwpn87wydTn"
    cp -r ${zbench-zig}/* "$TMPDIR/deps/zbench-0.10.0-YTdc7-cmAQCnYOFNUAy3wZ-Sx9-_r8lW4uwpn87wydTn/"

    zig build \
      -Doptimize=ReleaseFast \
      --prefix $out \
      --system "$TMPDIR/deps"

    # Ad-hoc code sign for macOS accessibility permissions
    rcodesign sign $out/bin/skhd

    runHook postBuild
  '';

  meta = {
    description = "Zig rewrite of skhd - simple hotkey daemon for macOS";
    homepage = "https://github.com/jackielii/skhd.zig";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.darwin;
    mainProgram = "skhd";
  };
}
