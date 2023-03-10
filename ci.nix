# This file provides all the buildable and cacheable packages and
# package outputs in your package set. These are what gets built by CI,
# so if you correctly mark packages as
#
# - broken (using `meta.broken`),
# - unfree (using `meta.license.free`), and
# - locally built (using `preferLocalBuild`)
#
# then your CI will be able to build and cache only those packages for
# which this is possible.

let
  # Pin nixpkgs for Hercules CI, which uses an empty NIX_PATH
  pinnedPkgs = builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/nixos/nixpkgs/archive/49596eb4e50b18337aad3b73317371bcd4e3b047.tar.gz";
    sha256 = "1yifdz6q1p5jzsf89d3gk0nha48969kgw32air4ibyga8d7133px";
  };
in
{ pkgs ? import pinnedPkgs { } }:

with builtins;
let
  system = pkgs.system;
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isCompatible = p: (elem system (p.meta.platforms or [ ])) && !(elem system (p.meta.badPlatforms or [ ]));
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: { name = n; value = v; };

  concatMap = builtins.concatMap or (f: xs: concatLists (map f xs));

  flattenPkgs = s:
    let
      f = p:
        if shouldRecurseForDerivations p then flattenPkgs p
        else if isDerivation p then [ p ]
        else [ ];
    in
    concatMap f (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = import ./default.nix { inherit pkgs; };

  nurPkgs =
      (listToAttrs
        (map (n: nameValuePair n nurAttrs.${n})
          (filter (n: !isReserved n)
            (attrNames nurAttrs))));

in
with { inherit (pkgs.lib) mapAttrs filterAttrs recurseIntoAttrs; }; recurseIntoAttrs rec {
  buildPkgs = filterAttrs (k: v: isBuildable v) nurPkgs;
  compatiblePkgs = filterAttrs (k: v: isCompatible v) buildPkgs;
  cachePkgs = filterAttrs (k: v: isCacheable v) compatiblePkgs;

  buildOutputs = mapAttrs (k: v: outputsOf v) buildPkgs;
  compatibleOutputs = mapAttrs (k: v: outputsOf v) compatiblePkgs;
  cacheOutputs = mapAttrs (k: v: outputsOf v) cachePkgs;
}
