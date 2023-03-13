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
  pathNixpkgs = builtins.tryEval <nixpkgs>;
  nixpkgsUrl =
    "https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz";
  nixpkgs =
    if pathNixpkgs.success
    then pathNixpkgs.value
    else builtins.fetchTarball { url = nixpkgsUrl; };

  overlays = import ./overlays;
  system = builtins.currentSystem;
in
{ pkgs ? import nixpkgs { overlays = [ overlays.maintainer ]; inherit system; } }:

with builtins;
let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isCompatible = p: (elem system (p.meta.platforms or [ ])) && !(elem system (p.meta.badPlatforms or [ ]));
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  isCacheable = p: !(p.preferLocalBuild or false) && (p.meta.license.free or true);
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
with { inherit (pkgs.lib) mapAttrs mapAttrsToList filterAttrs recurseIntoAttrs; }; rec {
  buildPkgs = filterAttrs (k: v: isBuildable v) nurPkgs;
  compatiblePkgs = filterAttrs (k: v: isCompatible v) buildPkgs;
  cachePkgs = filterAttrs (k: v: isCacheable v) compatiblePkgs;

  buildOutputs = mapAttrsToList (k: v: outputsOf v) buildPkgs;
  compatibleOutputs = mapAttrsToList (k: v: outputsOf v) compatiblePkgs;
  cacheOutputs = mapAttrsToList (k: v: outputsOf v) cachePkgs;
}
