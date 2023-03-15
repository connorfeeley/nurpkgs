# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

source $stdenv/setup

# Unpack directly into output directory
mkdir -p $out
tar -I 'xz -T0' -xf $src --strip-components=2 --exclude=gnu --exclude=data -C $out

# Fix script paths
patchShebangs $out

# Hack around lack of libtinfo in NixOS
ln -s $ncurses/lib/libncursesw.so.6 $out/lib/lnx64.o/libtinfo.so.5

# Patch ELFs
for f in $out/bin/unwrapped/lnx64.o/*; do
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $f || true
done

# Always run without graphical dependencies
wrapProgram $out/bin/xsct --add-flags "-nodisp"
