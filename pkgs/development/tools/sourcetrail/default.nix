{ lib, stdenv, fetchurl, fetchFromGitHub, callPackage, writeScript, fetchpatch, cmake
, wrapQtAppsHook, qt5, boost, llvmPackages, gcc, jdk, jre, maven, pythonPackages
, coreutils, which, desktop-file-utils, shared-mime-info, imagemagick, libicns
, sqlite, tinyxml, fmt, project_options, pkgconfig, gtest, catch2, trompeloeil
}:

let
  appPrefixDir = if stdenv.isDarwin then
    "$out/Applications/Sourcetrail.app/Contents"
  else
    "$out/opt/sourcetrail";
  appBinDir =
    if stdenv.isDarwin then "${appPrefixDir}/MacOS" else "${appPrefixDir}/bin";
  appResourceDir = if stdenv.isDarwin then
    "${appPrefixDir}/Resources"
  else
    "${appPrefixDir}/share";

  setupFiles = fetchFromGitHub {
    owner = "OpenSourceSourceTrail";
    repo = "setup";
    rev = "c297a0c48ee0798e09d976e990dd50c90d58bc19";
    hash = "sha256-B1RkouqPg8AhyN1KJAbciPm9hsnEWhzUWW/L0FBR06s=";
  };

in stdenv.mkDerivation rec {
  pname = "sourcetrail-ng";
  # NOTE: skip 2020.4.35 https://github.com/CoatiSoftware/Sourcetrail/pull/1136
  version = "af5ead41959d0657803fb2e5a47e684840959f2e";

  src = fetchFromGitHub {
    owner = "OpenSourceSourceTrail";
    repo = "Sourcetrail";
    rev = version;
    hash = "sha256-oP32h91l0KMRCHWpq2yefVbRT40DHS6BswBpSIZR3j4=";
    fetchSubmodules = true;
  };

  patches = let
    url = commit:
      "https://github.com/CoatiSoftware/Sourcetrail/commit/${commit}.patch";
  in [
    # ./disable-failing-tests.patch # FIXME: 5 test cases failing due to sandbox
  ];

  nativeBuildInputs = [
    cmake
    # gtest
    # catch2
    # trompeloeil
    pkgconfig
    jdk
    wrapQtAppsHook
    desktop-file-utils
    imagemagick
    sqlite
    tinyxml
    fmt.dev
    project_options
  ] ++ lib.optional (stdenv.isDarwin) libicns
    ++ lib.optionals doCheck testBinPath;
  buildInputs = [ boost shared-mime-info ]
    ++ (with qt5; [ qtbase qtsvg ]) ++ (with llvmPackages; [ libclang llvm ]);
  binPath = [ gcc jre maven which ];
  testBinPath = binPath ++ [ coreutils ];

  cmakeFlags = [
    "-DBoost_USE_STATIC_LIBS=OFF"
    "-DBUILD_CXX_LANGUAGE_PACKAGE=ON"
    "-DBUILD_JAVA_LANGUAGE_PACKAGE=OFF"
    "-DBUILD_PYTHON_LANGUAGE_PACKAGE=OFF"
    "-DSOURCETRAIL_CMAKE_VERBOSE=ON"
    "-DCMAKE_VERBOSE_MAKEFILE=ON"
  ] ++ lib.optionals doCheck [
    "-DENABLE_UNIT_TEST=ON"
    "-DENABLE_INTEGRATION_TEST=ON"
    "-DENABLE_E2E_TEST=ON"
  ] ++ lib.optional stdenv.isLinux
    "-DCMAKE_PREFIX_PATH=${llvmPackages.clang-unwrapped}"
    ++ lib.optional stdenv.isDarwin
    "-DClang_DIR=${llvmPackages.clang-unwrapped}";

  postPatch = let
    major = "2023";
    minor = "8";
    patch = "14";
  in ''
    # Upstream script obtains it's version from git:
    # https://github.com/CoatiSoftware/Sourcetrail/blob/master/cmake/version.cmake
    cat > cmake/version.cmake <<EOF
    set(GIT_BRANCH "")
    set(GIT_COMMIT_HASH "${version}")
    set(GIT_VERSION_NUMBER "")
    set(VERSION_YEAR "${major}")
    set(VERSION_MINOR "${minor}")
    set(VERSION_COMMIT "${patch}")
    set(BUILD_TYPE "Release")
    set(VERSION_STRING "${major}.${minor}.${patch}")
    EOF

    # Sourcetrail attempts to copy clang headers from the LLVM store path
    substituteInPlace CMakeLists.txt \
      --replace "\''${LLVM_BINARY_DIR}" '${lib.getLib llvmPackages.clang-unwrapped}' \
      --replace 'URL "https://github.com/aminya/project_options/archive/refs/tags/v0.26.3.zip"' "SOURCE_DIR ${project_options}" \
      --replace 'ENABLE_CONAN' 'DISABLE_CONAN' \
      --replace 'find_package(SQLite3 CONFIG REQUIRED)' "pkg_check_modules(SQLITE REQUIRED sqlite3)" \
      --replace '# Settings ---------------------------------------------------------------------' 'find_package(PkgConfig REQUIRED)' \
      --replace 'find_package(TinyXML CONFIG REQUIRED)' "pkg_check_modules(TINYXML REQUIRED tinyxml)"

    substituteInPlace CMakeLists.txt src/core/CMakeLists.txt src/lib_cxx/CMakeLists.txt src/external/CMakeLists.txt \
      --replace 'TinyXML::TinyXML' ' ''${TINYXML_LIBRARIES}' \
      --replace ' SQLite::SQLite3' ' ''${SQLITE_LIBRARIES}'

    substituteInPlace src/external/CMakeLists.txt \
      --replace ' SQLite::SQLite' ' ''${SQLITE_LIBRARIES}'

    substituteInPlace src/indexer/CMakeLists.txt \
      --replace 'Sourcetrail::lib_gui' 'Sourcetrail::lib_gui ''${SQLITE_LIBRARIES}'

    patchShebangs script
  '';

  # Directory layout for Linux:
  #
  # Sourcetrail doesn't use the usual cmake install() commands and instead uses
  # its own bash script for packaging. Since we're not able to reuse the script,
  # we'll have to roll our own in nixpkgs.
  #
  # Sourcetrail currently assumes one of the following two layouts for the
  # placement of its files:
  #
  # AppImage Layout       Traditional Layout
  # ├── bin/              ├── sourcetrail*
  # │   └── sourcetrail*  └── data/
  # └── share/
  #     └── data/         sourcetrail: application executable
  #                       data: contains assets exlusive to Sourcetrail
  #
  # The AppImage layout is the one currently used by the upstream project for
  # packaging its Linux port. We can't use this layout as-is for nixpkgs,
  # because Sourcetrail treating $out/share/data as its own might lead to
  # conflicts with other packages when linked into a Nix profile.
  #
  # On the other hand, the traditional layout isn't used by the upstream project
  # anymore so there's a risk that it might become unusable at any time in the
  # future. Since it's hard to detect these problems at build time, it's not a
  # good idea to use this layout for packaging in nixpkgs.
  #
  # Considering the problems with the above layouts, we go with the third
  # option, a slight variation of the AppImage layout:
  #
  # nixpkgs
  # ├── bin/
  # │   └── sourcetrail@ (symlink to opt/sourcetrail/bin/sourcetrail)
  # └── opt/sourcetrail/
  #     ├── bin/
  #     │   └── sourcetrail*
  #     └── share/
  #         └── data/
  #
  # Upstream install script:
  # https://github.com/OpenSourceSourceTrail/Sourcetrail/blob/master/setup/Linux/createPackages.sh
  installPhase = ''
    runHook preInstall

    mkdir -p ${appResourceDir}
    cp -R ../bin/app/data ${appResourceDir}
    cp -R ../bin/app/user/projects ${appResourceDir}/data/fallback
    rm -r ${appResourceDir}/data/install ${appResourceDir}/data/*_template.xml

    mkdir -p "${appBinDir}"
    cp app/Sourcetrail ${appBinDir}/sourcetrail
    cp app/sourcetrail_indexer ${appBinDir}/sourcetrail_indexer
    wrapQtApp ${appBinDir}/sourcetrail \
      --prefix PATH : ${lib.makeBinPath binPath}

    mkdir -p $out/bin
  '' + lib.optionalString (stdenv.isLinux) ''
    ln -sf ${appBinDir}/sourcetrail $out/bin/sourcetrail

    desktop-file-install --dir=$out/share/applications \
      --set-key Exec --set-value ${appBinDir}/sourcetrail \
      ${setupFiles}/Linux/data/sourcetrail.desktop

    mkdir -p $out/share/mime/packages
    cp ${setupFiles}/Linux/data/sourcetrail-mime.xml $out/share/mime/packages/

    for size in 48 64 128 256 512; do
      mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps/
      convert ${appResourceDir}/data/gui/icon/logo_1024_1024.png \
        -resize ''${size}x''${size} \
        $out/share/icons/hicolor/''${size}x''${size}/apps/sourcetrail.png
    done
  '' + lib.optionalString (stdenv.isDarwin) ''
    # change case (some people *might* choose a case sensitive Nix store)
    mv ${appBinDir}/sourcetrail{,.tmp}
    mv ${appBinDir}/{sourcetrail.tmp,Sourcetrail}
    mv ${appBinDir}/sourcetrail_indexer ${appResourceDir}/Sourcetrail_indexer

    ln -sf ${appBinDir}/Sourcetrail $out/bin/sourcetrail

    cp app/bundle_info.plist ${appPrefixDir}/Info.plist

    mkdir -p ${appResourceDir}/icon.iconset
    for size in 16 32 128 256 512; do
      convert ${appResourceDir}/data/gui/icon/logo_1024_1024.png \
        -resize ''${size}x''${size} \
        ${appResourceDir}/icon.iconset/icon_''${size}x''${size}.png
      convert ${appResourceDir}/data/gui/icon/logo_1024_1024.png \
        -resize $(( 2 * size ))x$(( 2 * size )) \
        ${appResourceDir}/icon.iconset/icon_''${size}x''${size}@2x.png
    done
    png2icns ${appResourceDir}/icon.icns \
      ${appResourceDir}/icon.iconset/icon_{16x16,32x32,128x128,256x256,512x512,512x512@2x}.png

    mkdir -p ${appResourceDir}/project.iconset
    for size in 16 32 64 128 256 512; do
      convert ${appResourceDir}/data/gui/icon/project_256_256.png \
        -resize ''${size}x''${size} \
        ${appResourceDir}/project.iconset/icon_''${size}x''${size}.png
      convert ${appResourceDir}/data/gui/icon/project_256_256.png \
        -resize $(( 2 * size ))x$(( 2 * size )) \
        ${appResourceDir}/project.iconset/icon_''${size}x''${size}@2x.png
    done
    png2icns ${appResourceDir}/project.icns \
      ${appResourceDir}/project.iconset/icon_{16x16,32x32,128x128,256x256,512x512,512x512@2x}.png
  '' + ''
    runHook postInstall
  '';

  # This has to be done manually in the installPhase because the actual binary
  # lives in $out/opt/sourcetrail/bin, which isn't covered by wrapQtAppsHook
  dontWrapQtApps = true;

  # FIXME: Some test cases are disabled in the patch phase.
  # FIXME: Tests are disabled on some platforms because of faulty detection
  # logic for libjvm.so. Should work with manual configuration.
  doCheck = false; # !stdenv.isDarwin && stdenv.isx86_64;

  meta = with lib; {
    homepage = "https://github.com/OpenSourceSourceTrail/Sourcetrail";
    description = "A cross-platform source explorer for C/C++";
    platforms = platforms.all;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ midchildan ];
  };
}