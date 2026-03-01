{
  lib,
  stdenv,
  fetchFromGitHub,
  deno,
  cacert,
  jq,
}:

let
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "schpet";
    repo = "linear-cli";
    rev = "v${version}";
    hash = "sha256-qhvU7oLe4nQPG6jSZWAzxkOENXJYPLQfNK2VVL2f1Dw=";
  };

  denoCache = stdenv.mkDerivation {
    name = "linear-cli-deno-cache-${version}";
    inherit src;
    nativeBuildInputs = [
      deno
      cacert
      jq
    ];

    buildPhase = ''
      export DENO_DIR="$out"
      export HOME="$(mktemp -d)"

      # Install all deps from deno.json/deno.lock
      deno install --frozen

      # Prune non-reproducible data from the cache (inspired by nixpkgs PR #407434).
      # registry.json files contain all published versions for a package and etags,
      # both of which change over time and break the FOD hash.
      for f in $(find "$DENO_DIR" -name registry.json -type f); do
        jq --sort-keys '{name, versions: (.versions | to_entries | map(select(.value.dist != null)) | from_entries)} ' "$f" > "$f.tmp"
        mv "$f.tmp" "$f"
      done

      # Remove SQLite WAL/SHM files and analysis caches
      find "$DENO_DIR" -name '*-shm' -o -name '*-wal' -o -name 'dep_analysis_cache_v2' -o -name 'node_analysis_cache_v2' -o -name 'v8_code_cache_v2' | xargs rm -f
    '';

    installPhase = "true";

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash =
      {
        x86_64-linux = "sha256-H7KG+Pk4ERu9+itO2+O0xZA2a7PTX2WCEp5QEiWpljE=";
        aarch64-darwin = "sha256-RDDxy1KsQ4YAWxUHH+1vp7p9cV2FG5eXaK1tKBioS5U=";
      }
      .${stdenv.hostPlatform.system} or (throw "unsupported system: ${stdenv.hostPlatform.system}");
  };
in

stdenv.mkDerivation {
  pname = "linear-cli";
  inherit version src;

  nativeBuildInputs = [ deno ];

  buildPhase = ''
    export HOME="$(mktemp -d)"

    # Copy cache to writable location
    export DENO_DIR="$(mktemp -d)"
    cp -r ${denoCache}/* "$DENO_DIR/"
    chmod -R u+w "$DENO_DIR"

    # Run codegen to generate GraphQL types
    deno run --cached-only --allow-all npm:@graphql-codegen/cli/graphql-codegen-esm

    # Compile standalone binary
    deno compile --cached-only -A -o linear src/main.ts
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 linear $out/bin/linear
    runHook postInstall
  '';

  meta = {
    description = "CLI for Linear issue tracking";
    homepage = "https://github.com/schpet/linear-cli";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "linear";
  };
}
