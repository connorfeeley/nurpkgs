# SPDX-FileCopyrightText: 2023 Connor Feeley
# SPDX-License-Identifier: BSD-3-Clause
#
# SPDX-FileCopyrightText: 2003-2023 Eelco Dolstra and the Nixpkgs/NixOS contributors
# SPDX-License-Identifier: MIT

# This function downloads and unpacks a dmg file similarly to how fetchzip
# works. fetchzip was copied from the nixpkgs repo and modified to use undmg,
# instead of unzip.

{ lib, fetchurl, undmg, glibcLocalesUtf8 ? null }:

{
  # Optionally move the contents of the unpacked tree up one level.
  stripRoot ? false
, url ? ""
, urls ? [ ]
, extraPostFetch ? ""
, postFetch ? ""
, name ? "source"
, pname ? ""
, version ? ""
, nativeBuildInputs ? [ ]
, # Allows to set the extension for the intermediate downloaded
  # file. This can be used as a hint for the unpackCmdHooks to select
  # an appropriate unpacking tool.
  extension ? null
, ...
} @ args:


lib.warnIf (extraPostFetch != "") "use 'postFetch' instead of 'extraPostFetch' with 'fetchdmg'."

  (
    let
      tmpFilename =
        if extension != null
        then "download.${extension}"
        else baseNameOf (if url != "" then url else builtins.head urls);
    in

    fetchurl ((
      if (pname != "" && version != "") then
        {
          name = "${pname}-${version}";
          inherit pname version;
        }
      else
        { inherit name; }
    ) // {
      recursiveHash = true;

      downloadToTemp = true;

      # Have to pull in glibcLocalesUtf8 for undmg in setup-hook.sh to handle
      # UTF-8 aware locale:
      #   https://github.com/NixOS/nixpkgs/issues/176225#issuecomment-1146617263
      nativeBuildInputs = [ undmg glibcLocalesUtf8 ] ++ nativeBuildInputs;

      postFetch =
        ''
          unpackDir="$TMPDIR/unpack"
          mkdir "$unpackDir"
          cd "$unpackDir"

          renamed="$TMPDIR/${tmpFilename}"
          mv "$downloadedFile" "$renamed"
          unpackFile "$renamed"
          chmod -R +w "$unpackDir"
        ''
        + (if stripRoot then ''
          if [ $(ls -A "$unpackDir" | wc -l) != 1 ]; then
            echo "error: dmg file must contain a single file or directory."
            echo "hint: Pass stripRoot=false; to fetchdmg to assume flat list of files."
            exit 1
          fi
          fn=$(cd "$unpackDir" && ls -A)
          if [ -f "$unpackDir/$fn" ]; then
            mkdir $out
          fi
          mv "$unpackDir/$fn" "$out"
        '' else ''
          mv "$unpackDir" "$out"
        '')
        + ''
          ${postFetch}
        '' + ''
          ${extraPostFetch}
        ''

        # Remove non-owner write permissions
        # Fixes https://github.com/NixOS/nixpkgs/issues/38649
        + ''
          chmod 755 "$out"
        '';
    } // removeAttrs args [ "stripRoot" "extraPostFetch" "postFetch" "extension" "nativeBuildInputs" ])
  )
