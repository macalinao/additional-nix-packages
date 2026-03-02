{ self, ... }:
{
  flake.overlays.default =
    final: prev:
    let
      system = prev.stdenv.hostPlatform.system;
    in
    self.packages.${system};
}
