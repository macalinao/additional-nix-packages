---
name: verify-nixpkgs-conventions
description: This skill should be used when the user asks to "verify a package", "check nixpkgs conventions", "lint package", "fix package for nixpkgs", "make package nixpkgs-ready", or wants to ensure a package in packages/ follows upstream nixpkgs contributing conventions.
argument-hint: "[package name]"
---

# Verify & Fix nixpkgs Conventions

Check a package in `packages/<name>/package.nix` against upstream nixpkgs conventions and fix any issues found.

## Steps

### 1. Read the package

Read `packages/<name>/package.nix` to understand its current state, build system, and structure.

### 2. Fetch the nixpkgs contributing guide

Fetch the upstream conventions directly to ensure checks are current:

- **Contributing guide**: https://raw.githubusercontent.com/NixOS/nixpkgs/master/CONTRIBUTING.md
- **pkgs/by-name README**: https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/by-name/README.md
- **Package conventions**: https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/README.md

Read through these and extract the relevant rules for the package's build system.

### 3. Check and fix all conventions

Apply every applicable fix in-place to `packages/<name>/package.nix`. The common issues are listed below, but defer to the upstream guides fetched in step 2 as the source of truth.

#### finalAttrs pattern (most important)

- **Must use**: `buildFooModule (finalAttrs: { ... })` instead of `buildFooModule rec { ... }`
- Replace bare `${version}` refs with `${finalAttrs.version}`
- Use `tag = finalAttrs.version` or `tag = "v${finalAttrs.version}"` instead of `rev = "v${version}"`
- Use `${finalAttrs.src.rev}` for commit hashes in ldflags instead of hardcoded values
- Note: not all builders support finalAttrs (e.g. `stdenv.mkDerivation` with complex `let` bindings may not benefit). Use judgment.

#### Meta block

- **`description`**: Single sentence, starts with capital letter, no period at end, no leading article ("A", "An", "The"), must not start with the package name
- **`homepage`**: Required, must point to upstream project page
- **`license`**: Required, must match upstream license (e.g. `lib.licenses.mit`)
- **`maintainers`**: Required for new packages — use `maintainers = with lib.maintainers; [ macalinao ];`
- **`mainProgram`**: Required if the package produces a binary

#### Code style

- **Function arguments**: List dependencies explicitly — `{ lib, buildGoModule, fetchFromGitHub }:` — avoid catch-all `...` unless necessary
- **No unnecessary string interpolation**: Write `tag = version;` not `tag = "${version}";` when the value is already a string
- **Conditional lists**: Use `lib.optional(s)` instead of `if cond then [ x ] else [ ]`
- **Variable naming**: Use `lowerCamelCase` for variables
- **File/directory naming**: Use lowercase with dashes (kebab-case)

#### Source fetching

- Use the appropriate fetcher: `fetchFromGitHub` for GitHub repos, `fetchFromGitLab` for GitLab, etc.
- Prefer `tag` over `rev` when fetching a tagged release
- Never include the `name` attribute in fetcher calls unless the default would be wrong

#### Build inputs

- `nativeBuildInputs` for build-time-only tools (compilers, code generators, pkg-config)
- `buildInputs` for runtime libraries that end up in the closure
- Do not mix the two

### 4. Verify the package still builds

```bash
cd /Users/igm/proj/macalinao/additional-nix-packages
git add packages/<name>/package.nix
nix build .#<name>
```

If the build fails, diagnose and fix. Iterate until it builds successfully.

### 5. Report changes

Summarize what was changed and why, referencing the specific nixpkgs convention each fix addresses.
