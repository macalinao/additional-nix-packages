---
name: contribute-to-nixpkgs
description: This skill should be used when the user asks to "contribute to nixpkgs", "submit package upstream", "send to nixpkgs", "create nixpkgs PR", "update nixpkgs PR", or wants to submit or update a package from this repo to the upstream NixOS/nixpkgs repository.
argument-hint: "<package-name>"
---

# Contribute Package to nixpkgs

Submit or update a package from `additional-nix-packages` to the upstream nixpkgs repository.

## Prerequisites

- The package must already exist in `packages/<name>/package.nix` in this repo
- The nixpkgs checkout is at `~/proj/macalinao/nixpkgs`
- The nixpkgs repo has remotes: `origin` (macalinao/nixpkgs) and `upstream` (NixOS/nixpkgs)

## Steps

### 1. Check for existing branch and PR

Before creating anything new, check if a branch and PR already exist:

```bash
cd ~/proj/macalinao/nixpkgs
git branch --list '<name>-init'
gh search prs --repo NixOS/nixpkgs "<name>" --author macalinao --json number,title,url,state
```

- **If a branch exists**: check it out with `git checkout <name>-init`
- **If no branch exists**: ensure master is up to date, then create a new branch (see step 5)

### 2. Ensure nixpkgs master is up to date

```bash
cd ~/proj/macalinao/nixpkgs
git checkout master
git pull upstream master
git push origin master
```

If updating an existing branch, rebase it onto master:

```bash
git checkout <name>-init
git rebase master
```

### 3. Update package to nixpkgs conventions

Reference the [nixpkgs contributing guide](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md) and look at existing packages in `~/proj/macalinao/nixpkgs/pkgs/by-name/` for examples of current conventions.

Read `packages/<name>/package.nix` and apply these changes in-place:

- **finalAttrs pattern**: `buildFooModule rec {` -> `buildFooModule (finalAttrs: {` ... `})`
- **tag instead of rev**: `rev = "v${version}"` -> `tag = "v${finalAttrs.version}"`
- **Use finalAttrs.version**: Replace bare `${version}` refs with `${finalAttrs.version}`
- **Use finalAttrs.src.rev**: Replace any hardcoded commit hashes in ldflags with `${finalAttrs.src.rev}`
- **Add maintainers**: `maintainers = with lib.maintainers; [ macalinao ];`
- **Add passthru.tests.version**: Use `testers.testVersion` for CLI tools

Not all changes apply to every package -- only apply what's relevant.

### 4. Copy to nixpkgs

Determine the two-letter prefix from the package name (e.g., `gogcli` -> `go`, `hello` -> `he`).

```bash
mkdir -p ~/proj/macalinao/nixpkgs/pkgs/by-name/<prefix>/<name>
cp packages/<name>/package.nix ~/proj/macalinao/nixpkgs/pkgs/by-name/<prefix>/<name>/package.nix
```

No `all-packages.nix` entry needed -- `pkgs/by-name/` auto-discovers.

### 5. Verify

```bash
cd ~/proj/macalinao/nixpkgs && nix-build -A <name>
```

### 6. Commit, squash, and push

#### New package (no existing branch)

```bash
cd ~/proj/macalinao/nixpkgs
git checkout -b <name>-init
git add pkgs/by-name/<prefix>/<name>/package.nix
git commit -m "<name>: init at <version>"
git push -u origin <name>-init
```

#### Updating an existing branch

Commit the changes, then squash all commits on the branch into one:

```bash
cd ~/proj/macalinao/nixpkgs
git add pkgs/by-name/<prefix>/<name>/package.nix
git commit -m "<name>: <description of change>"
```

Squash all commits above master into a single commit:

```bash
git reset --soft $(git merge-base HEAD master)
git commit -m "<name>: init at <version>"
git push --force-with-lease origin <name>-init
```

### 7. Create or update PR

#### Fetch the official PR template

Always fetch the current template from the repo to stay in sync:

```bash
gh api repos/NixOS/nixpkgs/contents/.github/PULL_REQUEST_TEMPLATE.md --jq '.content' | base64 -d > /tmp/nixpkgs-pr-template.md
```

Read the template, then construct the PR body with:

- A `## Description` section: `Add [<name>](<homepage>), <description>.`
- The `## Things done` checklist from the template, with the appropriate boxes checked based on what was actually tested/done (at minimum: the platform you built on, "Tested basic functionality" if verified, and "Fits CONTRIBUTING.md" if conventions were followed)

#### New PR

```bash
gh pr create --repo NixOS/nixpkgs \
  --title "<name>: init at <version>" \
  --body "<constructed body with description + official checklist>"
```

#### Update existing PR

```bash
gh pr edit <pr-number> --repo NixOS/nixpkgs \
  --body "<constructed body with description + official checklist>"
```

### 8. Return to master

```bash
cd ~/proj/macalinao/nixpkgs && git checkout master
```

Report the PR URL to the user when done.
