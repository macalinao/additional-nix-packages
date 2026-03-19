{ pkgs, ... }:

let
  lintel = pkgs.callPackage ./packages/lintel/package.nix { };
in
{
  packages = [ pkgs.git ];

  cachix.pull = [
    "devenv"
    "igm"
  ];

  git-hooks.hooks = {
    nixfmt.enable = true;
    prettier.enable = true;
    lintel = {
      enable = true;
      name = "lintel";
      entry = "${lintel}/bin/lintel check";
      stages = [ "commit-msg" ];
    };
  };
}
