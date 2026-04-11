{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  deno,
  cacert,
  jq,
  testers,
}:

let
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "schpet";
    repo = "linear-cli";
    rev = "v${version}";
    hash = "sha256-FR6WuTKws75i0T00ASxr6wTHYH8MNOdboJcDYD0aYVM=";
  };

  denortArch =
    {
      x86_64-linux = "x86_64-unknown-linux-gnu";
      aarch64-linux = "aarch64-unknown-linux-gnu";
      x86_64-darwin = "x86_64-apple-darwin";
      aarch64-darwin = "aarch64-apple-darwin";
    }
    .${stdenv.hostPlatform.system} or (throw "unsupported system: ${stdenv.hostPlatform.system}");

  # denort is the runtime binary that `deno compile` embeds into its output.
  # `deno compile` unconditionally downloads this from dl.deno.land at build
  # time, which fails inside the Nix sandbox. Fetch it separately, pinned to
  # the nixpkgs deno version, and seed it into DENO_DIR before `deno compile`
  # runs so it finds it without touching the network.
  denortZip = fetchurl {
    url = "https://dl.deno.land/release/v${deno.version}/denort-${denortArch}.zip";
    hash =
      {
        x86_64-linux = "sha256-kvYW0T9L7avvgeKAA0AwPGpybit8jrNg0y2oIXMWclQ=";
        aarch64-linux = "sha256-pBMiHG54QYWf8deoKGvvjma5tYCXfuOzksVfz6ONdAw=";
        x86_64-darwin = "sha256-L6pl28Fy873sA/KgImaWHnwBLwo5/DxQnKx6gaftWos=";
        aarch64-darwin = "sha256-E+/cRnsthOgIMdpw8ozbdMqiyLxYhYBwur0vmFUbkAI=";
      }
      .${stdenv.hostPlatform.system};
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

    # `deno install` resolves native npm packages (e.g. lefthook) for the
    # current system only, so cache contents still differ per platform.
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash =
      {
        x86_64-linux = "sha256-KZRsMHzzxITHgXzWoonXVI5vch0RGHKUf+1VcetFBUQ=";
        aarch64-linux = "sha256-tTlsAnzKMI/90uFaU9O7tty36o1gXfV+7RazJsIDfQQ=";
        x86_64-darwin = "sha256-pOVSM2VA1MG9oCHQoLo411vKd1xfC41GnQNis4xgkLw=";
        aarch64-darwin = "sha256-iLCjuAfDA8IGO63LSkaHCUKo7JgFGuasN4HpPYATptw=";
      }
      .${stdenv.hostPlatform.system} or (throw "unsupported system: ${stdenv.hostPlatform.system}");
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "linear-cli";
  inherit version src;

  nativeBuildInputs = [ deno ];

  # deno compile embeds data in the binary; strip removes it
  dontStrip = true;

  buildPhase = ''
    export HOME="$(mktemp -d)"

    # Copy cache to writable location
    export DENO_DIR="$(mktemp -d)"
    cp -r ${denoCache}/* "$DENO_DIR/"
    chmod -R u+w "$DENO_DIR"

    # Seed the denort binary where `deno compile` expects to find it.
    # Without this, deno compile tries to download it at build time.
    mkdir -p "$DENO_DIR/dl/release/v${deno.version}"
    cp ${denortZip} "$DENO_DIR/dl/release/v${deno.version}/denort-${denortArch}.zip"

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

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
    command = "NO_COLOR=1 linear --version";
  };

  meta = {
    description = "CLI for Linear issue tracking";
    homepage = "https://github.com/schpet/linear-cli";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "linear";
  };
})
