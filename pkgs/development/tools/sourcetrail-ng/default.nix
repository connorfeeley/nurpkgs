{ lib
, stdenv
, fetchFromGitHub
, cmake
, wrapQtAppsHook
, qt5
, boost
, llvmPackages
, gcc
, coreutils
, which
, desktop-file-utils
, shared-mime-info
, imagemagick
, libicns
, sqlite
, tinyxml
, fmt
, project_options
, pkg-config
, substituteAll
  # Darwin-only
, CoreFoundation
  # For tests
, gtest
, catch2_3
, trompeloeil
, ninja
}:

let
  appPrefixDir =
    if stdenv.isDarwin then
      "$out/Applications/Sourcetrail.app/Contents"
    else
      "$out/opt/sourcetrail";
  appBinDir =
    if stdenv.isDarwin then "${appPrefixDir}/MacOS" else "${appPrefixDir}/bin";
  appResourceDir =
    if stdenv.isDarwin then
      "${appPrefixDir}/Resources"
    else
      "${appPrefixDir}/share";

  setupFiles = fetchFromGitHub {
    owner = "OpenSourceSourceTrail";
    repo = "setup";
    rev = "c297a0c48ee0798e09d976e990dd50c90d58bc19";
    hash = "sha256-B1RkouqPg8AhyN1KJAbciPm9hsnEWhzUWW/L0FBR06s=";
  };

  ver = {
    version = "8f7f43ad880b13230ea9ffdc7c323dbedf2cd5d0";
    # Fields must not have leading a zero
    year = "2023";
    month = "8";
    day = "14";
  };

  clang-unwrapped = setClangFlags llvmPackages.clang-unwrapped;

  setClangFlags = package: package.overrideAttrs (oldAttrs: {
    cmakeFlags = oldAttrs.cmakeFlags ++ [
      "-DLLVM_ENABLE_PROJECTS:STRING=clang"
      "-DLLVM_ENABLE_RTTI:BOOL=ON"
      "-DCLANG_LINK_CLANG_DYLIB:BOOL=ON"
      "-DLLVM_LINK_LLVM_DYLIB:BOOL=ON"
      "-DLLVM_TARGETS_TO_BUILD=host"
    ];
  });

in
stdenv.mkDerivation rec {
  pname = "sourcetrail-ng";
  inherit (ver) version;

  src = fetchFromGitHub {
    owner = "OpenSourceSourceTrail";
    repo = "Sourcetrail";
    rev = version;
    hash = "sha256-ThwuC/xm9RDF0m545Uii1FioGUFRpOJn8ElxRUmJAbw=";
    fetchSubmodules = true;
  };

  patches = [
    (substituteAll {
      src = ./0001-disable-conan-and-use-pkgconfig-for-dependencies.patch;
      inherit project_options;
    })
    ./0002-use-correct-catch2-alias.patch
    (substituteAll {
      src = ./0003-Revert-build-Remove-mac-from-CMake.patch;
      inherit setupFiles;
    })
    ./0004-fix-darwin-build.patch
    ./0005-add-missing-vector-include.patch
    ./0006-disable-failing-tests.patch
    ./0008-fully-quality-format-generic_format.patch
  ] ++ lib.optional (stdenv.isDarwin) ./0007-disable-failing-tests-on-darwin.patch;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    wrapQtAppsHook
    desktop-file-utils
    imagemagick
    sqlite
    tinyxml
    fmt.dev
  ] ++ lib.optionals doCheck [
    gtest.dev
    catch2_3
    trompeloeil
  ] ++ lib.optional (stdenv.isDarwin) libicns
  ++ lib.optional (stdenv.isDarwin) qt5.qtmacextras
  ++ lib.optionals doCheck testBinPath;
  buildInputs = [ boost shared-mime-info ]
    ++ (with qt5; [ qtbase qtsvg ]) ++ ([
    # llvmPackages.libclang
    llvmPackages.llvm
    (llvmPackages.clang)
  ]);
  # Added to sourcetrail wrapper's PATH
  binPath = [ llvmPackages.clang gcc which ];
  testBinPath = binPath ++ [ coreutils ];

  cmakeFlags = [
    "-DBoost_USE_STATIC_LIBS=OFF"

    "-DClang_DIR=${clang-unwrapped.dev}/lib/cmake/clang"
    "-DBUILD_CXX_LANGUAGE_PACKAGE=ON"
    "-DCMAKE_PREFIX_PATH=${clang-unwrapped.dev}/lib/cmake/clang"
  ] ++ lib.optionals doCheck [
    "-DENABLE_UNIT_TEST=ON"
    "-DENABLE_E2E_TEST=ON"
    "-DENABLE_INTEGRATION_TEST=OFF" # Broken by sandbox
  ];

  postPatch =
    let
      inherit (ver) year month day;
    in
    ''
      # Upstream script obtains it's version from git:
      # https://github.com/OpenSourceSourceTrail/Sourcetrail/blob/master/cmake/version.cmake
      cat > cmake/version.cmake <<EOF
      set(GIT_BRANCH "")
      set(GIT_COMMIT_HASH "${version}")
      set(GIT_VERSION_NUMBER "")
      set(VERSION_YEAR "${year}")
      set(VERSION_MINOR "${month}")
      set(VERSION_COMMIT "${day}")
      set(BUILD_TYPE "Release")
      set(VERSION_STRING "${year}.${month}.${day}")
      EOF
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
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/OpenSourceSourceTrail/Sourcetrail";
    description = "A cross-platform source explorer for C/C++ (maintained fork)";
    platforms = platforms.all;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ cfeeley ];
  };
}
