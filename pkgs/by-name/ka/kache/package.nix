{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cacert,
  coreutils,
  bashInteractive,
  zsh,
  stdenv,
  xcbuild,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "kache";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "kunobi-ninja";
    repo = "kache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1O4JrN2zzKS7QgBT2fnih2W+zvEqBT5dvEuxCuyU3Kg=";
  };

  cargoHash = "sha256-6fA+IMcUtpPZZoVPWr15pUAPwxwsO2gTHtmzG5qqUjo=";

  # Build the frontend and companion engine; the workspace also contains library
  # crates, an end-to-end test crate and a service crate that are not
  # shipped here.
  cargoBuildFlags = [
    "--package"
    "kache"
    "--bins"
  ];
  # Restrict to unit tests: the integration tests under tests/ are an
  # end-to-end harness that runs kache as a RUSTC_WRAPPER and expects a
  # discoverable rustc/sysroot, which the build sandbox cannot provide.
  cargoTestFlags = [
    "--package"
    "kache"
    "--lib"
    "--bins"
  ];

  # Tests that talk to a loopback mock HTTP server still build a reqwest
  # client, which panics unless a system CA bundle can be loaded.
  nativeCheckInputs = [
    cacert
    bashInteractive
    zsh
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ xcbuild ];
  # The native process fixture embeds sleep and locates cp beside it.
  env.KACHE_TEST_SLEEP = "${coreutils}/bin/sleep";
  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  # On Darwin, the cache-key tests fold in the macOS SDK identity via
  # `xcrun --sdk "$SDKROOT" --show-sdk-version`. There is no system xcrun in
  # the sandbox, and xcbuild's xcrun only resolves SDKs by name, not by the
  # store path stdenv puts in SDKROOT, so let it fall back to `macosx`.
  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    unset SDKROOT
  '';

  checkFlags = [
    # Upstream's own regression test for transient state-file read failures
    # under the Nix build sandbox (kache#756). It chmods the state file to
    # 000 and then expects the learned state to reactivate once readable
    # again; under the sandbox's parallel test load the follow-up lease is
    # still declined and the test fails.
    "--skip=incremental_policy::tests::unreadable_state_declines_without_destroying_learned_state"
    # Waits at most 5s for a background prefetch task to record its failure;
    # times out under the parallel test load of a busy builder.
    "--skip=daemon::tests::prefetch_import_failure_is_counted_as_failure"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Spawns /usr/bin/sandbox-exec, which cannot apply a nested profile
    # inside the Darwin build sandbox (exits 71).
    "--skip=fallback::macos::tests::policy_distinguishes_denied_and_allowed_output"
    # The daemon execution tests re-exec themselves as a client compiler
    # fixture. Inside the Darwin build sandbox the daemon declines them
    # ("compiler process isolation requires local execution"), nested
    # sandbox-exec is not permitted, and the fixture compilers never signal
    # ready or report their exit status, so none of these can pass there.
    "--skip=daemon::execution::tests::disconnected_accepted_compiler_is_cancelled_and_reaped"
    "--skip=daemon::execution::tests::draining_before_commit_releases_worker_without_starting_a_compiler"
    "--skip=daemon::execution::tests::execution_handoff_streams_two_compilers_without_serializing_or_mixing_clients"
    "--skip=daemon::execution::tests::execution_jobserver_descriptors_reach_only_the_compiler"
    "--skip=daemon::execution::tests::execution_keeps_a_silent_compiler_alive_past_the_daemon_idle_timeout"
    "--skip=daemon::execution::tests::execution_rejects_sandboxed_client_using_kernel_identity"
    "--skip=daemon::execution::tests::only_accepted_execution_marks_build_activity"
    "--skip=daemon::execution::tests::original_compiler_shim_uses_the_clients_relative_path"
    "--skip=daemon::execution::tests::prepared_compiler_never_runs_without_commit_and_releases_its_resources"
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
