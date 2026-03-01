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
      export DENO_DIR="$(pwd)/.deno-cache"
      export HOME="$(mktemp -d)"

      # Install all deps from deno.json/deno.lock
      deno install --allow-scripts --frozen

      # Cache the denort runtime binary needed by deno compile.
      # This downloads the platform-specific denort zip into DENO_DIR.
      echo 'console.log("hello")' > /tmp/dummy.ts
      deno compile --output /tmp/dummy /tmp/dummy.ts 2>/dev/null || true
      rm -f /tmp/dummy /tmp/dummy.ts

      # Prune non-reproducible data from the cache (inspired by nixpkgs PR #407434).
      # registry.json files contain all published versions for a package and etags,
      # both of which change over time and break the FOD hash.
      # Extract name@version pairs from deno.lock's npm section.
      VERSIONS_FILE="$(mktemp)"
      jq -r '
        .npm // {} | keys[] | split("@") as $parts |
        if ($parts[0] == "") then
          ("@" + $parts[1]) + " " + ($parts[2] | split("_")[0])
        else
          $parts[0] + " " + ($parts[1] | split("_")[0])
        end
      ' deno.lock > "$VERSIONS_FILE"

      # Prune each registry.json to only versions referenced in deno.lock
      for f in $(find "$DENO_DIR" -name registry.json -type f); do
        PKG_NAME=$(jq -r '.name' "$f")
        KEEP_VERSIONS=$({ grep -F "$PKG_NAME " "$VERSIONS_FILE" || true; } | awk '{print $2}' | jq -R . | jq -s .)
        jq --sort-keys --argjson keep "$KEEP_VERSIONS" \
          '{name, versions: (.versions | to_entries | map(select(.key as $k | $keep | index($k))) | from_entries)}' \
          "$f" > "$f.tmp"
        mv "$f.tmp" "$f"
      done

      # Remove all SQLite databases and WAL/SHM files (non-deterministic)
      find "$DENO_DIR" \( \
        -name '*-shm' -o -name '*-wal' -o \
        -name 'check_cache_v2' -o \
        -name 'dep_analysis_cache_v2' -o \
        -name 'fast_check_cache_v2' -o \
        -name 'node_analysis_cache_v2' -o \
        -name 'v8_code_cache_v2' -o \
        -name '.deno.lock.poll' \
      \) -delete

      # Normalize volatile "// denoCacheMetadata={...}" comments in JSR/remote cached files.
      # These contain per-request HTTP headers (cf-ray, date, x-guploader-uploadid, etc.)
      # that differ on every fetch. Keep only the url field which Deno needs for cache lookups.
      find "$DENO_DIR/remote" -type f | while read -r f; do
        META_LINE=$(grep '// denoCacheMetadata=' "$f" || true)
        if [ -n "$META_LINE" ]; then
          URL=$(echo "$META_LINE" | sed 's|.*// denoCacheMetadata=||' | jq -r '.url')
          grep -v '// denoCacheMetadata=' "$f" > "$f.tmp"
          printf '// denoCacheMetadata={"headers":{},"url":"%s"}' "$URL" >> "$f.tmp"
          mv "$f.tmp" "$f"
        fi
      done

      # Remove non-deterministic npm lifecycle script marker files (.scripts-warned-*)
      find "$DENO_DIR" -name '.scripts-warned-*' -delete

      # Prune HTTP metadata (etags, timestamps) from URL cache metadata
      find "$DENO_DIR" -name 'metadata.json' -type f | while read -r f; do
        jq --sort-keys 'del(.headers.etag, .headers.Etag, .now, .date)' "$f" > "$f.tmp" 2>/dev/null && mv "$f.tmp" "$f" || rm -f "$f.tmp"
      done
    '';

    installPhase = ''
      cp -r "$DENO_DIR" "$out"
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash =
      {
        x86_64-linux = "sha256-SWIqonf4TUeJ9fEnY8KIMn/loaRRal8yuyUg5vSmuo4=";
        aarch64-darwin = "sha256-6BAmlErFC//TRjP2wteMWEgnhV+G5pWb7ouvfs5xxxw=";
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
