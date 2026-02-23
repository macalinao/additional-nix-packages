{ pkgs, inputs, ... }:

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
      entry = "${inputs.lintel.packages.${pkgs.system}.lintel}/bin/lintel check";
      stages = [ "commit-msg" ];
    };
  };
}
