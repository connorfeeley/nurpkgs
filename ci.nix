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
  pinnedPkgs =
    (builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/nixos/nixpkgs/archive/49596eb4e50b18337aad3b73317371bcd4e3b047.tar.gz";
      sha256 = "1yifdz6q1p5jzsf89d3gk0nha48969kgw32air4ibyga8d7133px";
    });
in
{ pkgs ? import pinnedPkgs { } }:

let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: builtins.isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: { name = n; value = v; };

  concatMap = builtins.concatMap or (f: xs: builtins.concatLists (map f xs));

  flattenPkgs = s:
    let
      f = p:
        if shouldRecurseForDerivations p then flattenPkgs p
        else if isDerivation p then [ p ]
        else [ ];
    in
    builtins.concatMap f (builtins.attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = import ./default.nix { inherit pkgs; };

  nurPkgs =
    flattenPkgs
      (builtins.listToAttrs
        (map (n: nameValuePair n nurAttrs.${n})
          (builtins.filter (n: !isReserved n)
            (builtins.attrNames nurAttrs))));

in
rec {
  buildPkgs = builtins.filter isBuildable nurPkgs;
  cachePkgs = builtins.filter isCacheable buildPkgs;

  buildOutputs = builtins.concatMap outputsOf buildPkgs;
  cacheOutputs = builtins.concatMap outputsOf cachePkgs;
}
