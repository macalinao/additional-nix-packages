{
  addDriverRunpath,
  alsa-lib,
  callPackage,
  flite,
  gamemode,
  glfw3-minecraft,
  jdk17,
  jdk21,
  jdk25,
  jdk8,
  kdePackages,
  lib,
  libGL,
  libdecor,
  libjack2,
  libpulseaudio,
  libusb1,
  libx11,
  libxcursor,
  libxext,
  libxrandr,
  libxxf86vm,
  openal,
  pciutils,
  pipewire,
  stdenv,
  symlinkJoin,
  udev,
  vulkan-loader,
  wayland,
  wrapGAppsHook3,
  xrandr,

  additionalLibs ? [ ],
  additionalPrograms ? [ ],
  controllerSupport ? stdenv.hostPlatform.isLinux,
  gamemodeSupport ? stdenv.hostPlatform.isLinux,
  jdks ? [
    jdk25
    jdk21
    jdk17
    jdk8
  ],
  msaClientID ? null,
  textToSpeechSupport ? stdenv.hostPlatform.isLinux,
}:

assert lib.assertMsg (
  controllerSupport -> stdenv.hostPlatform.isLinux
) "controllerSupport only has an effect on Linux.";

assert lib.assertMsg (
  textToSpeechSupport -> stdenv.hostPlatform.isLinux
) "textToSpeechSupport only has an effect on Linux.";

let
  unwrapped = callPackage ./unwrapped.nix { inherit msaClientID; };

  inherit (unwrapped.meta) mainProgram;

  # On Darwin the launcher is installed as an app bundle; the wrapped binary
  # lives inside it and is additionally exposed through `bin/`.
  launcherBinary =
    if stdenv.hostPlatform.isDarwin then
      "Applications/FjordLauncher.app/Contents/MacOS/${mainProgram}"
    else
      "bin/${mainProgram}";
in

symlinkJoin {
  __structuredAttrs = true;
  strictDeps = true;

  pname = "fjordlauncher-unlocked";
  inherit (unwrapped) version;

  paths = [ unwrapped ];

  nativeBuildInputs = [
    kdePackages.wrapQtAppsHook
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux wrapGAppsHook3;

  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtimageformats
    kdePackages.qtsvg
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux kdePackages.qtwayland;

  postBuild =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      # Required for org.gtk.Settings.FileChooser
      gappsWrapperArgsHook
      qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
    ''
    + ''
      wrapQtAppsHook
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/bin
      ln -s $out/${launcherBinary} $out/bin/${mainProgram}
    '';

  qtWrapperArgs =
    let
      runtimeLibs = [
        (lib.getLib stdenv.cc.cc)
        ## native versions
        glfw3-minecraft
        openal

        ## openal
        alsa-lib
        libjack2
        libpulseaudio
        pipewire

        ## glfw
        libGL
        libx11
        libxcursor
        libxext
        libxrandr
        libxxf86vm
        wayland
        libdecor

        udev # oshi

        vulkan-loader # VulkanMod's lwjgl
      ]
      ++ lib.optional textToSpeechSupport flite
      ++ lib.optional gamemodeSupport gamemode.lib
      ++ lib.optional controllerSupport libusb1
      ++ additionalLibs;

      runtimePrograms = [
        pciutils # need lspci
        xrandr # needed for LWJGL [2.9.2, 3) https://github.com/LWJGL/lwjgl/issues/128
      ]
      ++ additionalPrograms;
    in
    # One argument per element, as __structuredAttrs passes them verbatim
    [
      "--set"
      "NIX_LAUNCHER_WRAPPER"
      "${placeholder "out"}/${launcherBinary}"
      "--prefix"
      "FJORDLAUNCHER_JAVA_PATHS"
      ":"
      (lib.makeSearchPath "bin/java" jdks)
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      "--set"
      "LD_LIBRARY_PATH"
      "${addDriverRunpath.driverLink}/lib:${lib.makeLibraryPath runtimeLibs}"
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath runtimePrograms)
    ];

  passthru = {
    inherit unwrapped;
  };

  meta = {
    inherit (unwrapped.meta)
      description
      longDescription
      homepage
      changelog
      license
      maintainers
      mainProgram
      platforms
      ;
  };
}
