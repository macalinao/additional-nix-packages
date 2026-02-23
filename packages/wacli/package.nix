{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "wacli";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "steipete";
    repo = "wacli";
    rev = "v0.2.0";
    hash = "sha256-tJ5d33VVW5aYvacHJEVm8cVKVtpdWCIOdHNy2WTR4Cg=";
  };

  vendorHash = "sha256-0mHZjZHQBHTlPzVT4ScyRBSaQ4Z8FEm2GFfsPF6Tjrw=";

  tags = [ "sqlite_fts5" ];

  subPackages = [ "cmd/wacli" ];

  meta = {
    description = "WhatsApp CLI built on whatsmeow";
    homepage = "https://github.com/steipete/wacli";
    mainProgram = "wacli";
  };
}
