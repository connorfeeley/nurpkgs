# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  # lib = import ./lib { inherit pkgs; }; # functions
  # modules = import ./modules; # NixOS modules
  # overlays = import ./overlays; # nixpkgs overlays

  apple_complete = pkgs.callPackage ./pkgs/os-specific/darwin/apple_complete { };
  aranet4 = pkgs.callPackage ./pkgs/development/python-modules/aranet4 { };
  cpprestsdk = pkgs.callPackage ./pkgs/development/libraries/cpprestsdk { };
  maclaunch = pkgs.callPackage ./pkgs/os-specific/darwin/maclaunch { };
  nmos-cpp = pkgs.callPackage ./pkgs/development/libraries/nmos-cpp { };
  qemu-xilinx = pkgs.callPackage ./pkgs/applications/virtualization/qemu { };
  toronto-backgrounds = pkgs.callPackage ./pkgs/data/misc/toronto-backgrounds { };
  xsct = pkgs.callPackage ./pkgs/applications/misc/xsct { };
}
