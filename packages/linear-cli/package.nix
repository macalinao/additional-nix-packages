{
  lib,
  stdenv,
  fetchFromGitHub,
  deno,
  cacert,
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
    ];

    buildPhase = ''
      export DENO_DIR="$out"
      export HOME="$(mktemp -d)"

      # Install all deps from deno.json/deno.lock
      deno install --frozen
    '';

    installPhase = "true";

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-wsSD/QFbs/jiHTdMkNk7PmRtI4bFaZjY8Pxi73jkSF4=";
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
