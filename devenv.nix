{ pkgs, ... }:

{
  packages = [ pkgs.git ];

  cachix.pull = [
    "devenv"
    "igm"
  ];

  git-hooks.hooks.nixfmt.enable = true;
}
