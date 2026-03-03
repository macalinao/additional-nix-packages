---
name: contribute-to-nixpkgs
description: This skill should be used when the user asks to "contribute to nixpkgs", "submit package upstream", "send to nixpkgs", "create nixpkgs PR", or wants to submit a package from this repo to the upstream NixOS/nixpkgs repository.
argument-hint: "<package-name>"
---

# Contribute Package to nixpkgs

Submit a package from `additional-nix-packages` to the upstream nixpkgs repository.

## Prerequisites

- The package must already exist in `packages/<name>/package.nix` in this repo
- The nixpkgs checkout is at `~/proj/macalinao/nixpkgs`
- The nixpkgs repo has remotes: `origin` (macalinao/nixpkgs) and `upstream` (NixOS/nixpkgs)

## Steps

### 1. Ensure nixpkgs is on master and up to date

```bash
cd ~/proj/macalinao/nixpkgs
git checkout master
git pull upstream master
git push origin master
```

### 2. Update package to nixpkgs conventions

Reference the [nixpkgs contributing guide](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md) and look at existing packages in `~/proj/macalinao/nixpkgs/pkgs/by-name/` for examples of current conventions.

Read `packages/<name>/package.nix` and apply these changes in-place:

- **finalAttrs pattern**: `buildFooModule rec {` → `buildFooModule (finalAttrs: {` ... `})`
- **tag instead of rev**: `rev = "v${version}"` → `tag = "v${finalAttrs.version}"`
- **Use finalAttrs.version**: Replace bare `${version}` refs with `${finalAttrs.version}`
- **Use finalAttrs.src.rev**: Replace any hardcoded commit hashes in ldflags with `${finalAttrs.src.rev}`
- **Add maintainers**: `maintainers = with lib.maintainers; [ macalinao ];`

Not all changes apply to every package — only apply what's relevant.

### 3. Copy to nixpkgs

Determine the two-letter prefix from the package name (e.g., `gogcli` → `go`, `hello` → `he`).

```bash
mkdir -p ~/proj/macalinao/nixpkgs/pkgs/by-name/<prefix>/<name>
cp packages/<name>/package.nix ~/proj/macalinao/nixpkgs/pkgs/by-name/<prefix>/<name>/package.nix
```

No `all-packages.nix` entry needed — `pkgs/by-name/` auto-discovers.

### 4. Verify

Run both in parallel:

```bash
# From nixpkgs checkout — build the package
cd ~/proj/macalinao/nixpkgs && nix-build -A <name>

# From this repo — ensure flake still evaluates
nix flake check --no-build
```

### 5. Create branch and submit PR

From the nixpkgs checkout:

```bash
cd ~/proj/macalinao/nixpkgs
git checkout -b <name>-init
git add pkgs/by-name/<prefix>/<name>/package.nix
git commit -m "<name>: init at <version>"
git push -u origin <name>-init
```

Then create the PR against `NixOS/nixpkgs`. First, fetch the official PR template to use as the checklist:

```bash
gh api repos/NixOS/nixpkgs/contents/.github/PULL_REQUEST_TEMPLATE.md --jq '.content' | base64 -d > /tmp/nixpkgs-pr-template.md
```

Read the template, then construct the PR body with:

- A `## Description` section: `Add [<name>](<homepage>), <description>.`
- The `## Things done` checklist from the template, with the appropriate boxes checked based on what was actually tested/done (at minimum: the platform you built on, "Tested basic functionality" if verified, and "Fits CONTRIBUTING.md" if conventions were followed)

```bash
gh pr create --repo NixOS/nixpkgs \
  --title "<name>: init at <version>" \
  --body "<constructed body with description + official checklist>"
```

### 6. Return to master

```bash
cd ~/proj/macalinao/nixpkgs && git checkout master
```

Report the PR URL to the user when done.
