{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libgit2,
  rust-jemalloc-sys,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "biome";
  version = "2.4.4";

  src = fetchFromGitHub {
    owner = "biomejs";
    repo = "biome";
    rev = "@biomejs/biome@${finalAttrs.version}";
    hash = "sha256-d7FSqOOAcJ/llq+REPOCvJAbHFanLzgOuwcOURf+NPg=";
  };

  cargoHash = "sha256-g8ov3SrcpHuvdg7qbbDMbhYMSAGCxJgQyWY+W/Sh/pM=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libgit2
    rust-jemalloc-sys
    zlib
  ];

  cargoBuildFlags = [ "-p=biome_cli" ];

  doCheck = false;

  env = {
    BIOME_VERSION = finalAttrs.version;
    LIBGIT2_NO_VENDOR = 1;
  };

  meta = {
    description = "Toolchain of the web";
    homepage = "https://biomejs.dev/";
    changelog = "https://github.com/biomejs/biome/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "biome";
  };
})
