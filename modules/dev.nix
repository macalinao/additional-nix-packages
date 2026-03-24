{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    { pkgs, config, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          oxfmt.enable = true;
        };
      };

      pre-commit.settings.hooks = {
        treefmt.enable = true;
        lintel = {
          enable = true;
          name = "lintel";
          entry = "${config.packages.lintel}/bin/lintel check";
        };
      };

      devShells.default = pkgs.mkShell {
        packages = [ pkgs.git ];
        inputsFrom = [
          config.treefmt.build.devShell
        ];
        shellHook = config.pre-commit.installationScript;
      };
    };
}
