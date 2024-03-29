# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; config = { allowUnfree = true; }; };
          nurpkgs = import ./default.nix { inherit pkgs; };
          darwinPackages = nurpkgs.darwinPackages;
        in
        flake-utils.lib.filterPackages system (pkgs.lib.recursiveUpdate nurpkgs darwinPackages)
      );
      nixosModules = import ./modules;
      overlays.default = import ./overlay.nix;
    };
}
