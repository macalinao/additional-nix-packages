{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  cmark,
  gamemode,
  jdk17,
  kdePackages,
  libarchive,
  ninja,
  qrencode,
  stripJavaArchivesHook,
  tomlplusplus,
  vulkan-headers,
  zlib,
  msaClientID ? null,
}:

let
  libnbtplusplus = fetchFromGitHub {
    owner = "PrismLauncher";
    repo = "libnbtplusplus";
    rev = "3538933614059f0f44388a2b16f3db25ce42285b";
    hash = "sha256-6/8clF2yNhfonV16cfIkxVIzuB9i9ThxoLMxAo/fDuY=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;
  strictDeps = true;

  pname = "fjordlauncher-unlocked-unwrapped";
  version = "11.1.0.0";

  src = fetchFromGitHub {
    owner = "hero-persson";
    repo = "FjordLauncherUnlocked";
    tag = finalAttrs.version;
    hash = "sha256-4buIXVomMow9RvS6yBwPrvud/fJyE4AeYihN44vf//g=";
  };

  postUnpack = ''
    rm -rf source/libraries/libnbtplusplus
    ln -s ${libnbtplusplus} source/libraries/libnbtplusplus
  '';

  postPatch = ''
    # Ensure that instance shortcuts point to our final wrapper, rather than this unwrapped version
    substituteInPlace launcher/minecraft/ShortcutUtils.cpp \
      --replace-fail 'QApplication::applicationFilePath()' 'QProcessEnvironment::systemEnvironment().value("NIX_LAUNCHER_WRAPPER", QApplication::applicationFilePath())'
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Don't copy Qt and every other linked library into the app bundle (and
    # don't write a qt.conf that hides the Nix Qt plugins); the bundle links
    # against the Nix store and is wrapped with wrapQtAppsHook instead.
    substituteInPlace launcher/CMakeLists.txt \
      --replace-fail 'COMPONENT bundle' 'COMPONENT bundle EXCLUDE_FROM_ALL'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
    kdePackages.extra-cmake-modules
    jdk17
    stripJavaArchivesHook
  ];

  buildInputs = [
    cmark
    kdePackages.qtbase
    kdePackages.qtnetworkauth
    libarchive
    qrencode
    tomlplusplus
    vulkan-headers
    zlib
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux gamemode;

  cmakeFlags = [
    # downstream branding
    (lib.cmakeFeature "Launcher_BUILD_PLATFORM" "nixpkgs")
    # extra-cmake-modules is a native input, so with strictDeps its config is
    # not added to CMAKE_PREFIX_PATH automatically
    (lib.cmakeFeature "ECM_DIR" "${kdePackages.extra-cmake-modules}/share/ECM/cmake")
  ]
  ++ lib.optionals (msaClientID != null) [
    (lib.cmakeFeature "Launcher_MSA_CLIENT_ID" (toString msaClientID))
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # disable built-in updater
    (lib.cmakeFeature "MACOSX_SPARKLE_UPDATE_FEED_URL" "")
    (lib.cmakeFeature "CMAKE_INSTALL_PREFIX" "${placeholder "out"}/Applications/")
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # The executable target installs into `fjordlauncher.app` while resources
    # and jars go to `FjordLauncher.app`; merge them on case-sensitive stores.
    if [ -d $out/Applications/fjordlauncher.app ] \
      && ! [ $out/Applications/fjordlauncher.app -ef $out/Applications/FjordLauncher.app ]; then
      cp -rT $out/Applications/fjordlauncher.app $out/Applications/FjordLauncher.app
      rm -r $out/Applications/fjordlauncher.app
    fi

    # Normally installed with the excluded `bundle` component
    install -Dm644 ../launcher/qtlogging.ini \
      $out/Applications/FjordLauncher.app/Contents/Resources/qtlogging.ini
  '';

  doCheck = true;

  dontWrapQtApps = true;

  meta = {
    description = "Prism Launcher fork with support for alternative auth servers and no DRM";
    longDescription = ''
      Fork of Fjord Launcher, itself a fork of Prism Launcher. Allows you to
      have multiple, separate instances of Minecraft (each with their own
      mods, texture packs, saves, etc) and helps you manage them and their
      associated options with a simple interface. Supports alternative
      authentication servers and does not require a Microsoft account.
    '';
    homepage = "https://github.com/hero-persson/FjordLauncherUnlocked";
    changelog = "https://github.com/hero-persson/FjordLauncherUnlocked/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ macalinao ];
    mainProgram = "fjordlauncher";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
