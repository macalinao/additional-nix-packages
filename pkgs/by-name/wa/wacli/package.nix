{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGo127Module (finalAttrs: {
  __structuredAttrs = true;

  pname = "wacli";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "steipete";
    repo = "wacli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wWTrU7aIIwKvPPaCjO7A+x3FIF7oMYhQoefU5CGlhGo=";
  };

  vendorHash = "sha256-8Wo54XTj1tLshcAuiStmy+ux8R2tEHUaVSTCZQBMdnE=";

  # Enables SQLite FTS5 (full-text search) in mattn/go-sqlite3 for message history search
  tags = [ "sqlite_fts5" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/wacli" ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "WhatsApp CLI built on whatsmeow";
    homepage = "https://github.com/steipete/wacli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "wacli";
  };
})
