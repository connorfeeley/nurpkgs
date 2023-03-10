{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
        let nurpkgs = import ./default.nix { pkgs = import nixpkgs { inherit system; }; };
        in flake-utils.lib.filterPackages system nurpkgs);

      herculesCI = { ... }: {
        onPush.default = {
          # Attributes here will be built for each push.
          outputs = { ... }:
            forAllSystems (system:
              let
                pkgs = import nixpkgs { inherit system; };
                ci = import ./ci.nix { };
              in
              pkgs.lib.recurseIntoAttrs ci.cachePkgs);
          # self.packages.${system});
        };
      };
    };
}
