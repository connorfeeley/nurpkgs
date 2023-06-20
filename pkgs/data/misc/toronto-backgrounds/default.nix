{ lib, pkgs, ... }:
let
  inherit (lib.strings) sanitizeDerivationName;

  # Not free in the "free software" sense, but very permissive:
  # - No attribution required
  # - May modify and redistribute; except "on other stock photo or wallpaper platforms")
  # https://www.pexels.com/license/
  # https://www.pexels.com/terms-of-service/
  license = lib.licenses.free;

  mkWallpaper = name': { class, url, hash }:
    let name = sanitizeDerivationName name';
    in
    pkgs.stdenv.mkDerivation rec {
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
        inherit url hash;
      };
      meta = { inherit license; };
    };

  # TODO: Add https://pbs.twimg.com/media/Fue1ydEWIAAfs0U?format=jpg&name=large / https://twitter.com/jamesmckz/status/1650487672773783552/photo/1

  torontoWallpapers = lib.mapAttrs (k: v: mkWallpaper k v) {
    "Old City Hall Bay Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/7039934/pexels-photo-7039934.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2";
      hash = "sha256-sapKhP9dGsDeERAoqRtLs7jEbx3GlhzHDuihKH3uED4=";
    };
    "Streetcar Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/6807184/pexels-photo-6807184.jpeg?cs=srgb&dl=pexels-ahmed-raza-khan-films-6807184.jpg&fm=jpg&w=6000&h=4000";
      hash = "sha256-YvUOybBKd9700z5+PA2wi0AUvZk4RWQ2Th89Dn7fU8g=";
    };
    "Streetcar Bay-Queen Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/6761658/pexels-photo-6761658.jpeg?cs=srgb&dl=pexels-ahmed-raza-khan-films-6761658.jpg&fm=jpg&w=4499&h=2999";
      hash = "sha256-YIxPvuWdc4L3AnXihO9z5Kk0QEthoP7iGgcl+5A59Xw=";
    };
    "Streetcar 504 Mirvish Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/6145923/pexels-photo-6145923.jpeg?cs=srgb&dl=pexels-ahmed-raza-khan-films-6145923.jpg&fm=jpg&w=6000&h=3773";
      hash = "sha256-ktFeddBTjLcR7HWbZj22bgI5eHcuq3+qPcd9uMpGbbA=";
    };
    "Streetcar Orange Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/6752012/pexels-photo-6752012.jpeg?cs=srgb&dl=pexels-ahmed-raza-khan-films-6752012.jpg&fm=jpg&w=5975&h=3983";
      hash = "sha256-KiziepRTQW7AD0QdhoENXbdzCEpWtNyhGz/nBxdLdaw=";
    };
    "Old City Hall Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/6003102/pexels-photo-6003102.jpeg?cs=srgb&dl=pexels-ahmed-raza-khan-films-6003102.jpg&fm=jpg&w=5337&h=4000";
      hash = "sha256-lcGbkHJGd4/8nb24dZZbFZgAwJJkQMTpPEcXKf7nWi8=";
    };
    "Park CN Tower Day" = {
      class = "light";
      url =
        "https://images.pexels.com/photos/137581/pexels-photo-137581.jpeg?cs=srgb&dl=pexels-scott-webb-137581.jpg&fm=jpg&w=5371&h=3497";
      hash = "sha256-ovu+rg//YAOdfJZvcdSSpmbiN8QyG9ITauIIdNiBTm4=";
    };
    "St. Andrew Night" = {
      class = "dark";
      url =
        "https://images.pexels.com/photos/3159900/pexels-photo-3159900.jpeg?cs=srgb&dl=pexels-andre-furtado-3159900.jpg&fm=jpg&w=3648&h=5472";
      hash = "sha256-j0gknTIl4tdaWWm2byBG71BkPog9CLZPndKJUXu7FRs=";
    };
    "Streetcar 506 College-Yonge" = {
      class = "dark";
      url = "https://unsplash.com/photos/OvKHfwmRq-o/download?ixid=MnwxMjA3fDB8MXxhbGx8MTl8fHx8fHwyfHwxNjc2MjU4Mjgx&force=true";
      hash = "sha256-7EzE/62Vc5AOzcYDlrSvaHz2WrIcpQ07rQxFTXtN0HI=";
    };
    "Glen Road Bridge" = {
      class = "light";
      # https://twitter.com/SwanBoatSteve/status/1632021109737508869/photo/1
      url = "https://pbs.twimg.com/media/FqYaefhWIAUiwAV?format=jpg";
      hash = "sha256-4rmYkaVa2uvtM5defXM6rNcQGJqgMnOgxWOi0qaxLo0=";
    };
    # Featuring Toronto's *official* mascot
    "Gooderman Flatiron Building Raccoon" = {
      class = "light";
      url = "https://media.blogto.com/articles/20211112-carlier-morejon-1.jpg?w=3840&height=1365&quality=100";
      hash = "sha256-ZNCWAs4Qnz34R0SQzLRVm4ZhmDmjdUH8ZxLqFK/3y/g=";
    };
  };
in
pkgs.stdenv.mkDerivation {
  pname = "toronto-backgrounds";
  version = "2023-03-10";

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

  passthru = {
    wallpapers = lib.mapAttrs' (k: v: lib.nameValuePair (sanitizeDerivationName k) v.passthru) torontoWallpapers;
    disableUpgrade = true;
  };

  meta = with lib; {
    description = "Personal collection of wallpaper images of Toronto, Canada";
    # https://www.pexels.com/terms-of-service/
    # https://www.pexels.com/license/
    inherit license;
    maintainers = [ maintainers.cfeeley ];
    platforms = platforms.all;
  };
}
