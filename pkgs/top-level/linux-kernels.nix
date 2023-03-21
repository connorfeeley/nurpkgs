# SPDX-FileCopyrightText: 2023 Connor Feeley
# SPDX-License-Identifier: BSD-3-Clause

# SPDX-FileCopyrightText: 2003-2023 Eelco Dolstra and the Nixpkgs/NixOS contributors
# SPDX-License-Identifier: MIT

{ pkgs
, linuxKernel
, config
, buildPackages
, callPackage
, makeOverridable
, recurseIntoAttrs
, dontRecurseIntoAttrs
, stdenv
, stdenvNoCC
, newScope
, lib
, fetchurl
, gcc10Stdenv
}:

with linuxKernel; rec {
  # kernelPatches = callPackage ../os-specific/linux/kernel/patches.nix { };

  kernels = recurseIntoAttrs (lib.makeExtensible (self: with self;
    let callPackage = newScope self; in {
      linux_xilinx = callPackage ../os-specific/linux/kernel/linux-xilinx.nix {
        kernelPatches = with kernelPatches; [ ];
      };
    }));

  /*  Linux kernel modules are inherently tied to a specific kernel.  So
    rather than provide specific instances of those packages for a
    specific kernel, we have a function that builds those packages
    for a specific kernel.  This function can then be called for
    whatever kernel you're using. */

  packagesFor = kernel_: lib.makeExtensible (self: with self;
    let callPackage = newScope self; in {
      inherit callPackage;
      kernel = kernel_;
      inherit (kernel) stdenv; # in particular, use the same compiler by default

      inherit (kernel) kernelOlder kernelAtLeast;
      amdgpu-pro = callPackage ../os-specific/linux/amdgpu-pro {
        libffi = pkgs.libffi.overrideAttrs (orig: rec {
          version = "3.3";
          src = fetchurl {
            url = "https://github.com/libffi/libffi/releases/download/v${version}/${orig.pname}-${version}.tar.gz";
            sha256 = "0mi0cpf8aa40ljjmzxb7im6dbj45bb0kllcd09xgmp834y9agyvj";
          };
        });
      };
    });

  xilinxPackages = {
    linux_xilinx = packagesFor kernels.linux_xilinx;
  };

  packages = recurseIntoAttrs (xilinxPackages);

  # manualConfig = callPackage ../os-specific/linux/kernel/manual-config.nix { };

  customPackage = { version, src, modDirVersion ? lib.versions.pad 3 version, configfile, allowImportFromDerivation ? true }:
    recurseIntoAttrs (packagesFor (manualConfig {
      inherit version src modDirVersion configfile allowImportFromDerivation;
    }));

  # Derive one of the default .config files
  linuxConfig =
    { src
    , version ? (builtins.parseDrvName src.name).version
    , makeTarget ? "defconfig"
    , name ? "kernel.config"
    ,
    }: stdenvNoCC.mkDerivation {
      inherit name src;
      depsBuildBuild = [ buildPackages.stdenv.cc ]
        ++ lib.optionals (lib.versionAtLeast version "4.16") [ buildPackages.bison buildPackages.flex ];
      postPatch = ''
        patchShebangs scripts/
      '';
      buildPhase = ''
        set -x
        make \
          ARCH=${stdenv.hostPlatform.linuxArch} \
          HOSTCC=${buildPackages.stdenv.cc.targetPrefix}gcc \
          ${makeTarget}
      '';
      installPhase = ''
        cp .config $out
      '';
    };

  buildLinux = attrs: callPackage ../os-specific/linux/kernel/generic.nix attrs;
}
