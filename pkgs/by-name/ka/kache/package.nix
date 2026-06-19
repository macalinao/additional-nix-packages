{
  lib,
  rustPlatform,
  fetchFromGitHub,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "kache";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "kunobi-ninja";
    repo = "kache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bOls4m1SVuIxoeF2/kCtIU+f11AO/1BFrxcWFXvGHIE=";
  };

  cargoHash = "sha256-XV7DRPaodZx5bL/neJj9KbjHVGZktD9Rumq1z55A8lM=";

  # Build only the main kache binary; the workspace also contains an
  # end-to-end test crate and a server crate that are not shipped here.
  cargoBuildFlags = [
    "--package"
    "kache"
  ];
  # Restrict to unit tests: the integration tests under tests/ are an
  # end-to-end harness that runs kache as a RUSTC_WRAPPER and expects a
  # discoverable rustc/sysroot, which the build sandbox cannot provide.
  cargoTestFlags = [
    "--package"
    "kache"
    "--bins"
  ];

  checkFlags = [
    # These tests reach out over the network and expect system CA
    # certificates, neither of which is available in the build sandbox.
    "--skip=planner_client::tests::test_resolve_prefetch_plan_with_config"
    "--skip=planner_client::tests::test_resolve_prefetch_plan_with_config_errors_on_bad_status"
    "--skip=planner_client::tests::test_resolve_prefetch_plan_with_do_nothing_disposition"
    # Flaky under the sandbox's high parallelism: stresses concurrent
    # SQLite access and intermittently fails with "database is locked".
    "--skip=store::tests::test_concurrent_put_remove_never_dangles"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Zero-copy, content-addressed Rust build cache using hardlinks locally and S3 for sharing";
    homepage = "https://github.com/kunobi-ninja/kache";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "kache";
  };
})
