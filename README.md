# additional-nix-packages

Additional Nix packages not yet available in nixpkgs.

## Packages

- **gogcli** (`gog`) - CLI tool for interacting with Google APIs (Gmail, Calendar, Drive, and more). [Source](https://github.com/steipete/gogcli)
- **wacli** - WhatsApp CLI built on whatsmeow. [Source](https://github.com/steipete/wacli)

## Usage

### Run directly

```sh
nix run github:macalinao/additional-nix-packages#gogcli
```

### Add to your flake

```nix
{
  inputs.additional-nix-packages.url = "github:macalinao/additional-nix-packages";

  outputs = { self, nixpkgs, additional-nix-packages, ... }: {
    # Use additional-nix-packages.packages.${system}.gogcli
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
    inputs.additional-nix-packages.packages.${pkgs.system}.gogcli
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
