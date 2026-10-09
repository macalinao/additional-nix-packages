{
  lib,
  stdenv,
  stdenvNoCC,
  buildGo127Module,
  fetchFromGitHub,
  bun,
  nodejs,
  bubblewrap,
  sqlite,
  writableTmpDirAsHomeHook,
  versionCheckHook,
}:

buildGo127Module (finalAttrs: {
  __structuredAttrs = true;
  strictDeps = true;

  pname = "msgvault";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "kenn-io";
    repo = "msgvault";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bici+SEEgCygqWuWcQLaQNWh6hgKO13xJTRsV3d6hvM=";
  };

  vendorHash = "sha256-B1/cu5XXvT1q13+CILzUGc4fiJLODscvPdJ6HLXJZYY=";

  # The daemon launches the sandboxed Codex helper through Bubblewrap at a
  # hardcoded FHS path.
  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace internal/peoplesweep/codex_process_linux.go \
      --replace-fail '"/usr/bin/bwrap"' '"${lib.getExe bubblewrap}"'
  '';

  # sqlite-vec's cgo bindings include <sqlite3.h>; go-sqlite3 still links its
  # bundled amalgamation.
  buildInputs = [ sqlite ];

  tags = [
    "fts5"
    "sqlite_vec"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X go.kenn.io/msgvault/cmd/msgvault/cmd.Version=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/msgvault" ];

  # Not preBuild: buildGoModule also runs that in the vendoring derivation.
  postConfigure = ''
    # Embed the prebuilt browser UI beside the compilation stub.
    cp -R ${finalAttrs.passthru.web}/. internal/web/dist/
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    # The daemon verifies the static Codex proxy bridge installed next to it
    # against a digest linked in at build time.
    CGO_ENABLED=0 go build -trimpath -buildvcs=false -ldflags="-s -w" \
      -o "$NIX_BUILD_TOP/msgvault-codex-bridge" ./cmd/msgvault-codex-bridge
    ldflags+=("-X" "go.kenn.io/msgvault/internal/peoplesweep.codexBridgeSHA256=$(sha256sum "$NIX_BUILD_TOP/msgvault-codex-bridge" | cut -d' ' -f1)")
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm755 "$NIX_BUILD_TOP/msgvault-codex-bridge" "$out/bin/msgvault-codex-bridge"
  '';

  # Stripping would change the bridge binary and break its linked digest; both
  # binaries are already built with -s -w.
  dontStrip = true;

  # Upstream shards its several-thousand-test suite across CI jobs; too slow here.
  doCheck = false;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";

  passthru = {
    webNodeModules = stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-web-node-modules";
      inherit (finalAttrs) version src;

      sourceRoot = "${finalAttrs.src.name}/web";

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

      nativeBuildInputs = [
        bun
        writableTmpDirAsHomeHook
      ];

      dontConfigure = true;
      dontFixup = true;

      # Install optional native packages for every platform so a single hash
      # covers all systems.
      buildPhase = ''
        runHook preBuild

        export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
        bun install \
          --cpu="*" \
          --os="*" \
          --force \
          --frozen-lockfile \
          --ignore-scripts \
          --no-progress

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        cp -R node_modules $out

        runHook postInstall
      '';

      outputHash = "sha256-S8r2kec8QFvC9ozb86euF6EGZyEqJpbPHaO+QWNEzIo=";
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };

    web = stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-web";
      inherit (finalAttrs) version src;

      __structuredAttrs = true;
      strictDeps = true;

      nativeBuildInputs = [ nodejs ];

      buildPhase = ''
        runHook preBuild

        cp -R ${finalAttrs.passthru.webNodeModules} web/node_modules
        chmod -R u+w web/node_modules
        patchShebangs web/node_modules

        # API client sources are committed, so only the Vite build is needed.
        (cd web && node node_modules/vite/bin/vite.js build)

        # Same staging and validation as upstream's `make web-embed`.
        find internal/web/dist -mindepth 1 -maxdepth 1 ! -name stub.html -exec rm -rf {} +
        cp -R web/dist/. internal/web/dist/
        node scripts/check-web-assets.mjs

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        cp -R web/dist $out

        runHook postInstall
      '';
    };
  };

  meta = {
    description = "Offline archive with search, analytics, and AI query over email and chat history";
    homepage = "https://github.com/kenn-io/msgvault";
    changelog = "https://github.com/kenn-io/msgvault/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "msgvault";
  };
})
