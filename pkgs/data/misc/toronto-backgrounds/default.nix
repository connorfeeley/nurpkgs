{ lib, pkgs, ... }:
let
  inherit (lib.strings) sanitizeDerivationName;

  # Not free in the "free software" sense, but very permissive:
  # - No attribution required
  # - May modify and redistribute; except "on other stock photo or wallpaper platforms")
  # https://www.pexels.com/license/
  # https://www.pexels.com/terms-of-service/
  license = lib.licenses.free;

  mkWallpaper = name': { class, url, sha256 }:
    let name = sanitizeDerivationName name';
    in pkgs.stdenv.mkDerivation rec {
      pname = sanitizeDerivationName "toronto-${name}-backgrounds";
      version = "0.0.1";

      unpackPhase = "cp $src .";
      installPhase = ''
        mkdir -p $out/share/backgrounds
        cp ${src} $out/share/backgrounds/${sanitizeDerivationName name}.jpg
      '';

      passthru = { inherit name class; };

      src = pkgs.fetchurl {
        name = sanitizeDerivationName "${name}.jpg";
        inherit url sha256;
      };
      meta = { inherit license; };
    };

  torontoWallpapers = lib.mapAttrs (k: v: mkWallpaper k v) {
    "Old City Hall Bay Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/7039934/pexels-photo-7039934.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2";
      sha256 = "sha256-sapKhP9dGsDeERAoqRtLs7jEbx3GlhzHDuihKH3uED4=";
    };
    "Streetcar Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/6807184/pexels-photo-6807184.jpeg?cs=srgb&dl=pexels-ahmed-raza-khan-films-6807184.jpg&fm=jpg&w=6000&h=4000";
      sha256 = "sha256-YvUOybBKd9700z5+PA2wi0AUvZk4RWQ2Th89Dn7fU8g=";
    };
    "Streetcar Bay-Queen Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/6761658/pexels-photo-6761658.jpeg?cs=srgb&dl=pexels-ahmed-raza-khan-films-6761658.jpg&fm=jpg&w=4499&h=2999";
      sha256 = "sha256-YIxPvuWdc4L3AnXihO9z5Kk0QEthoP7iGgcl+5A59Xw=";
    };
    "Streetcar 504 Mirvish Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/6145923/pexels-photo-6145923.jpeg?cs=srgb&dl=pexels-ahmed-raza-khan-films-6145923.jpg&fm=jpg&w=6000&h=3773";
      sha256 = "sha256-ktFeddBTjLcR7HWbZj22bgI5eHcuq3+qPcd9uMpGbbA=";
    };
    "Streetcar Orange Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/6752012/pexels-photo-6752012.jpeg?cs=srgb&dl=pexels-ahmed-raza-khan-films-6752012.jpg&fm=jpg&w=5975&h=3983";
      sha256 = "sha256-KiziepRTQW7AD0QdhoENXbdzCEpWtNyhGz/nBxdLdaw=";
    };
    "Old City Hall Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/6003102/pexels-photo-6003102.jpeg?cs=srgb&dl=pexels-ahmed-raza-khan-films-6003102.jpg&fm=jpg&w=5337&h=4000";
      sha256 = "sha256-lcGbkHJGd4/8nb24dZZbFZgAwJJkQMTpPEcXKf7nWi8=";
    };
    "Park CN Tower Day" = {
      class = "light";
      url =
        "https://images.pexels.com/photos/137581/pexels-photo-137581.jpeg?cs=srgb&dl=pexels-scott-webb-137581.jpg&fm=jpg&w=5371&h=3497";
      sha256 = "sha256-ovu+rg//YAOdfJZvcdSSpmbiN8QyG9ITauIIdNiBTm4=";
    };
    "St. Andrew Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/3159900/pexels-photo-3159900.jpeg?cs=srgb&dl=pexels-andre-furtado-3159900.jpg&fm=jpg&w=3648&h=5472";
      sha256 = "sha256-j0gknTIl4tdaWWm2byBG71BkPog9CLZPndKJUXu7FRs=";
    };
    "Streetcar 506 College-Yonge" = {
      class = "dark";
      url = "https://unsplash.com/photos/OvKHfwmRq-o/download?ixid=MnwxMjA3fDB8MXxhbGx8MTl8fHx8fHwyfHwxNjc2MjU4Mjgx&force=true";
      sha256 = "sha256-rlO68dZ0CS6uZMTvdNKOy3koKopUqJy1g7FNgKlSMrw=";
    };
    "Glen Road Bridge" = {
      class = "light";
      # https://twitter.com/SwanBoatSteve/status/1632021109737508869/photo/1
      url = "https://pbs.twimg.com/media/FqYaefhWIAUiwAV?format=jpg";
      sha256 = "sha256-sbRIcWZLcb5Vo5q3zcIrrmr20/+1yzQXPsFdNL8Iqf8=";
    };
  };
in
pkgs.stdenv.mkDerivation {
  name = "toronto-backgrounds";

  src = pkgs.symlinkJoin {
    name = "toronto-backgrounds";
    paths = builtins.attrValues torontoWallpapers;
  };

  dontUnpack = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/backgrounds
    cp -r $src/share/backgrounds/* $out/share/backgrounds
  '';

  passthru = lib.mapAttrs' (k: v: lib.nameValuePair (sanitizeDerivationName k) v.passthru) torontoWallpapers;

  meta = with lib; {
    description = "Personal collection of wallpaper images of Toronto, Canada";
    # https://www.pexels.com/terms-of-service/
    # https://www.pexels.com/license/
    inherit license;
    maintainers = [ maintainers.cfeeley ];
    platforms = platforms.all;
  };
}