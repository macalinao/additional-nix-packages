{
  lib,
  rustPlatform,
  fetchFromGitHub,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "batonpass";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "macalinao";
    repo = "batonpass";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T8ShJXLQhT+cKXkHNq61ptUUG+7JUYFYqlXPxp+OfII=";
  };

  cargoHash = "sha256-qB6nDpHvH54F/5dEdZmYm5rJsugSOjYoHRTmiGnOaCs=";

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Run a command with a share of the GNU make jobserver's tokens";
    homepage = "https://github.com/macalinao/batonpass";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    platforms = lib.platforms.unix;
    mainProgram = "baton";
  };
})
