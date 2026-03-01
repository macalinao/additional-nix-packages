---
name: Create Nix Derivation
description: This skill should be used when the user asks to "create a nix package", "add a package", "create a derivation", "package this repo", or provides a GitHub URL to package. Creates a Nix package derivation and integrates it into the flake.
argument_hint: "<github-repo>"
---

# Create Nix Derivation

Create a Nix package derivation and integrate it into the flake.

## Steps

1. **Analyze the repository** at the given GitHub URL:
   - Determine the language and build system (Rust/Cargo, Zig, Go, Deno/TypeScript, pre-built binaries, etc.)
   - Check the latest release/tag version
   - Identify build dependencies
   - Check if a flake.nix or Nix derivation already exists

2. **Get the source hash**:

   ```bash
   nix run nixpkgs#nix-prefetch-github -- <owner> <repo> --rev <tag>
   ```

3. **Create the package directory and derivation**:
   - Create `packages/<name>/package.nix` (use `package.nix`, NOT `default.nix`)
   - Follow the conventions from nixpkgs for the build system:
     - **Rust**: Use `rustPlatform.buildRustPackage`
     - **Zig**: Use `stdenv.mkDerivation` with `zig` nativeBuildInput, set `ZIG_LOCAL_CACHE_DIR` and `ZIG_GLOBAL_CACHE_DIR`
     - **Go**: Use `buildGoModule`
     - **Deno/TypeScript**: Use FOD for deno cache + `deno compile`
     - **Pre-built binaries**: Use `fetchurl` with per-platform sources
   - Use `lib.fakeHash` for unknown hashes, then build to get the correct hash from the error

4. **Add to flake.nix**:
   - Add to the `overlays.default` attrset
   - Add to the `packages` attrset in `eachDefaultSystem`
   - Use `callPackage ./packages/<name>/package.nix { }`

5. **Build and verify**:

   ```bash
   git add packages/<name>/package.nix  # nix needs files tracked by git
   nix build .#<name>
   ./result/bin/<binary> --version
   ```

6. **Iterate on hashes**: If using `lib.fakeHash`, update with the correct hash from the build error and rebuild.

## Package Conventions

- Package directory: `packages/<name>/package.nix`
- Always include a `meta` block with: `description`, `homepage`, `license`, `maintainers`, `mainProgram`
- Keep `version` as a `let` binding for easy updates
- For platform-specific packages, set `meta.platforms` appropriately
