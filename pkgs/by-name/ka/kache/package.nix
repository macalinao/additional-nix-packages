{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cacert,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "kache";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "kunobi-ninja";
    repo = "kache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M0L0B4/Gom2hT19XAHFclDOPbylN8dpjNXsEsuGgHjU=";
  };

  cargoHash = "sha256-M3beojPbL5tOUvhn7jxQ8o/N1lh9e5paaf9T45cI7nw=";

  # Build only the main kache binary; the workspace also contains library
  # crates, an end-to-end test crate and a service crate that are not
  # shipped here.
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

  # Tests that talk to a loopback mock HTTP server still build a reqwest
  # client, which panics unless a system CA bundle can be loaded.
  nativeCheckInputs = [ cacert ];
  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  checkFlags = [
    # Upstream's own regression test for transient state-file read failures
    # under the Nix build sandbox (kache#756). It chmods the state file to
    # 000 and then expects the learned state to reactivate once readable
    # again; under the sandbox's parallel test load the follow-up lease is
    # still declined and the test fails.
    "--skip=incremental_policy::tests::unreadable_state_declines_without_destroying_learned_state"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Zero-copy, content-addressed build cache for Rust and C/C++ with S3 and shared-filesystem remotes";
    homepage = "https://github.com/kunobi-ninja/kache";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "kache";
  };
})
