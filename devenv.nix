{ pkgs, ... }:

{
  packages = [ pkgs.git ];

  git-hooks.hooks.nixfmt.enable = true;
}
