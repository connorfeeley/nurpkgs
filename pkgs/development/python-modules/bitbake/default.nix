# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, buildFHSUserEnv
, buildFHSUserEnvBubblewrap
, writeScript
, autoPatchelfHook
, writeShellScriptBin
, symlinkJoin
, pkgs
}:
let
  poky = stdenv.mkDerivation rec {
    pname = "poky";
    version = "2021.1";

    src = fetchFromGitHub {
      owner = "Xilinx";
      repo = "poky";
      rev = "xlnx-rel-v${version}";
      hash = "sha256-B98hzkh49Le3sy1RwCtO5W7v8hJFYEfGTZFn70usCFw=";
    };
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/poky
      cp -r * $out/share/poky
    '';
  };

  fhs = buildFHSUserEnvBubblewrap rec {
    name = "bitbake-wrapper";
    targetPkgs = pkgs: (with pkgs; [
      bc
      binutils
      bzip2
      chrpath
      cpio
      diffstat
      expect
      file
      gcc8
      gdb
      git
      gnumake
      hostname
      kconfig-frontends
      xz
      ncurses
      patch
      perl
      python39 # python310 throws collection error with this poky
      rpcsvc-proto
      unzip
      util-linux
      wget
      which

      direnv
      nix-direnv

      glibcLocales
    ]);
    multiPkgs = null;
    extraOutputsToInstall = [ "dev" ];
    profile =
      let
        wrapperEnvar = "NIX_CC_WRAPPER_TARGET_HOST_${pkgs.stdenv.cc.suffixSalt}";
        # TODO limit export to native pkgs?
        nixconf = pkgs.writeText "nixvars.conf" ''
          # This exports the variables to actual build environments
          # From BB_ENV_EXTRAWHITE
          export LOCALE_ARCHIVE
          export ${wrapperEnvar}
          export NIX_DONT_SET_RPATH = "1"

          # Exclude these when hashing
          # the packages in yocto
          BB_HASHBASE_WHITELIST += " LOCALE_ARCHIVE \
                                    NIX_DONT_SET_RPATH \
                                    ${wrapperEnvar} "
        '';
      in
      ''
        # These are set by buildFHSUserEnvBubblewrap
        export BB_ENV_EXTRAWHITE=" LOCALE_ARCHIVE \
                                  ${wrapperEnvar} \
                                  $BB_ENV_EXTRAWHITE "

        # source the config for bibake equal to --postread
        export BBPOSTCONF="${nixconf}"
      '' + ''
        # ln -s $PWD /workdir

        # export PATH=$PATH:$PWD/scripts

        # export BB_ENV_EXTRAWHITE="''${BB_ENV_EXTRAWHITE:-}
        # ULTRIFILE_URL
        # CUR_SB_SDI_REMOTE_FILE_1
        # CUR_SB_SDI_REMOTE_FILE_1_NAME
        # CUR_SB_SDI_REMOTE_FILE_2
        # CUR_SB_SDI_REMOTE_FILE_2_NAME
        # CUR_SB_SDI_REMOTE_FILE_1_GOLDEN
        # CUR_SB_SDI_REMOTE_FILE_1_GOLDEN_NAME
        # CUR_SB_SDI_REMOTE_FILE_2_GOLDEN
        # CUR_SB_SDI_REMOTE_FILE_2_GOLDEN_NAME
        # CUR_SB_IP_REMOTE_FILE_1
        # CUR_SB_IP_REMOTE_FILE_1_NAME
        # CUR_SB_IP_REMOTE_FILE_2
        # CUR_SB_IP_REMOTE_FILE_2_NAME
        # CUR_SB_ZUP_BITFILE
        # CUR_SB_ZUP_BITFILE_NAME
        # CUR_SB_ZUP_XSA
        # CUR_SB_ZUP_XSA_NAME
        # CUR_SB_SDI_CPLD_APP_1
        # CUR_SB_SDI_CPLD_APP_1_NAME
        # CUR_SB_SDI_CPLD_APP_2
        # CUR_SB_SDI_CPLD_APP_2_NAME
        # CUR_SB_SDI_CPLD_UFM
        # CUR_SB_SDI_CPLD_UFM_NAME
        # CUR_SB_SDI_CPLD_GOLDEN
        # CUR_SB_SDI_CPLD_GOLDEN_NAME
        # CUR_SB_SDI_REMOTE_FILE_1_SHA
        # CUR_SB_SDI_REMOTE_FILE_2_SHA
        # CUR_SB_SDI_REMOTE_FILE_1_GOLDEN_SHA
        # CUR_SB_SDI_REMOTE_FILE_2_GOLDEN_SHA
        # CUR_SB_IP_REMOTE_FILE_1_SHA
        # CUR_SB_IP_REMOTE_FILE_2_SHA
        # CUR_SB_ZUP_BITFILE_SHA
        # CUR_SB_ZUP_XSA_SHA
        # CUR_SB_SDI_CPLD_APP_1_SHA
        # CUR_SB_SDI_CPLD_APP_2_SHA
        # CUR_SB_SDI_CPLD_UFM_SHA
        # CUR_SB_SDI_CPLD_GOLDEN_SHA
        # CUR_SB_ZUP_QSPI_TARBALL
        # CUR_SB_ZUP_QSPI_TARBALL_SHA"

        # . .env
        # . compute-version.sh
        # . scripts/set-current-vars.sh
        # . scripts/setup-env.sh
        # . setupsdk
      '';

    runScript = writeScript "${name}-wrapper" ''
      exec "$@"
    '';

    passthru = { inherit poky; };
  };

  wrapExecutable = prefix: executable: writeShellScriptBin (lib.removePrefix prefix executable) ''
    exec ${fhs}/bin/bitbake-wrapper ${executable} "$@"
  '';

  collection = symlinkJoin {
    name = "bitbake-collection";
    paths = [
      poky
      fhs
    ]
    ++ (map (exe: wrapExecutable (poky + "/share/poky/bitbake/bin/") exe)
      (lib.filesystem.listFilesRecursive (poky + "/share/poky/bitbake/bin")))
    ++ (map (exe: wrapExecutable (poky + "/share/poky/scripts/") exe)
      (lib.filesystem.listFilesRecursive (poky + "/share/poky/scripts")));
    passthru = { inherit poky; };
  };
in
collection
