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

  treefmt = {
    enable = true;
    config.programs = {
      nixfmt.enable = true;
      oxfmt.enable = true;
    };
  };

  git-hooks.hooks = {
    treefmt.enable = true;
    lintel = {
      enable = true;
      name = "lintel";
      entry = "${lintel}/bin/lintel check";
      stages = [ "commit-msg" ];
    };
  };
}
