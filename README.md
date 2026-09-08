# additional-nix-packages

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/macalinao/additional-nix-packages)

Additional Nix packages not yet available in nixpkgs.

## Packages

- **asimeow** - Smart command line macOS Time Machine exclusion manager for busy developers. [Source](https://github.com/mdnmdn/asimeow)
- **claude-devtools** - DevTools for Claude Code. [Source](https://github.com/matt1398/claude-devtools)
- **git-worktree-runner** (`git-gtr`, `gtr`) - Bash-based Git worktree manager with editor and AI tool integration. [Source](https://github.com/coderabbitai/git-worktree-runner)
- **kache** - Zero-copy, content-addressed build cache for Rust and C/C++. [Source](https://github.com/kunobi-ninja/kache)
- **kdl-lsp** - LSP server for the KDL Document Language. [Source](https://github.com/kdl-org/kdl-rs)
- **lintel** - Fast JSON Schema linter for JSON and YAML config files. [Source](https://github.com/lintel-rs/lintel)
- **mad** - Fast Markdown terminal renderer with syntax highlighting. [Source](https://github.com/macalinao/mad)
- **notifykit** - Notification CLI for macOS with Claude Code hook support. [Source](https://github.com/macalinao/notifykit)
- **protoc-gen-buffa**, **protoc-gen-buffa-packaging** - Protoc plugins for generating Rust code with buffa. [Source](https://github.com/anthropics/buffa)
- **protoc-gen-connect-rust** - Protoc plugin for generating ConnectRPC Rust service bindings. [Source](https://github.com/anthropics/connect-rust)
- **skhd-zig** (`skhd`) - Zig rewrite of skhd, a simple hotkey daemon for macOS. [Source](https://github.com/jackielii/skhd.zig)
- **wacli** - WhatsApp CLI built on whatsmeow. [Source](https://github.com/steipete/wacli)

## Usage

### Run directly

```sh
nix run github:macalinao/additional-nix-packages#wacli
```

### Add to your flake

```nix
{
  inputs.additional-nix-packages.url = "github:macalinao/additional-nix-packages";

  outputs = { self, nixpkgs, additional-nix-packages, ... }: {
    # Use additional-nix-packages.packages.${system}.wacli
  };
}
```

### Use the overlay

```nix
{
  inputs.additional-nix-packages.url = "github:macalinao/additional-nix-packages";

  outputs = { self, nixpkgs, additional-nix-packages, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ additional-nix-packages.overlays.default ];
      };
    in {
      # pkgs.wacli and the other packages are now available
    };
}
```

### Add to your devenv

In `devenv.yaml`, add the flake as an input:

```yaml
inputs:
  additional-nix-packages:
    url: github:macalinao/additional-nix-packages
```

Then use the packages in `devenv.nix`:

```nix
{ pkgs, inputs, ... }:

{
  packages = [
    inputs.additional-nix-packages.packages.${pkgs.system}.wacli
  ];
}
```

## Development

This repo uses [devenv](https://devenv.sh) for development.

```sh
devenv shell  # enter dev shell
devenv test   # run tests
```
