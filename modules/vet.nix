{ self, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      nixpkgs = inputs.nixpkgs;
      vet = pkgs.writeShellApplication {
        name = "vet";
        runtimeInputs = [
          pkgs.nixpkgs-vet
          pkgs.nix
          pkgs.coreutils
        ];
        text = ''
          set -euo pipefail
          work=$(mktemp -d)
          trap 'chmod -R +w "$work" 2>/dev/null; rm -rf "$work"' EXIT
          cp -r ${nixpkgs} "$work/nixpkgs"
          chmod -R u+w "$work/nixpkgs"
          cp -r ${self}/pkgs/by-name/. "$work/nixpkgs/pkgs/by-name/"
          export NIXPKGS_VET_NIX_PACKAGE=${pkgs.nix}
          exec nixpkgs-vet --base ${nixpkgs} "$work/nixpkgs"
        '';
      };
    in
    {
      apps.vet = {
        type = "app";
        program = "${vet}/bin/vet";
      };
    };
}
