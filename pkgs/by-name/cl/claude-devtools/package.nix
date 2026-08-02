{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "claude-devtools";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "matt1398";
    repo = "claude-devtools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+FqdFMeyZOL9HV5OfNdzSn5QE/d3vveO4QEYfk0WT38=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-Ikdmad6kGlES6CdIdfREAPCRZpkj3y8hX601DJy7Dl8=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
    makeWrapper
  ];

  # The standalone build runs the HTTP server without Electron; the
  # electron npm package is only a (script-disabled) devDependency.
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  buildPhase = ''
    runHook preBuild

    pnpm standalone:build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Drop devDependencies; only fastify, @fastify/cors and
    # @fastify/static are externalized from the server bundle.
    pnpm prune --prod --ignore-scripts

    mkdir -p $out/lib/claude-devtools/out
    cp -r dist-standalone node_modules package.json $out/lib/claude-devtools/
    # The server resolves the UI from ../out/renderer relative to the bundle.
    cp -r out/renderer $out/lib/claude-devtools/out/

    makeWrapper ${lib.getExe nodejs} $out/bin/claude-devtools \
      --add-flags "$out/lib/claude-devtools/dist-standalone/index.cjs"

    runHook postInstall
  '';

  meta = {
    description = "DevTools for Claude Code — inspect session logs, tool calls, token usage, subagents, and context window in a visual UI (standalone HTTP server)";
    homepage = "https://github.com/matt1398/claude-devtools";
    changelog = "https://github.com/matt1398/claude-devtools/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "claude-devtools";
  };
})
