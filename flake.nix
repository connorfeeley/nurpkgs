{
  description = "My personal NUR repository";
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
          pkgs = import nixpkgs { inherit system; };
          nurpkgs = import ./default.nix { inherit pkgs; };
          darwinPackages = nurpkgs.darwin;
        in flake-utils.lib.filterPackages system (pkgs.lib.recursiveUpdate nurpkgs darwinPackages)
        );
    };
}
