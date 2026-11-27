#!/bin/bash
# Build Wine-Plus from this source tree into a relocatable runner tarball.
#
#   wine-plus/build.sh [NAME]
#
# NAME defaults to wine-plus-<version>-amd64. The result is
#   $OUT/NAME/            the runner (bin/wine, bin/wineserver, lib/wine/...)
#   $OUT/NAME.tar.xz      the same as an archive with one top-level folder
#
# Environment:
#   OUT=dir             output directory (default: ../wine-plus-out next to the tree)
#   JOBS=n              parallel jobs (default: nproc)
#   CCACHE=1            compile through ccache
#   CONFIGURE_FLAGS=..  extra ./configure flags
#   STRIP=0             keep debug info (default: stripped)
#
# 64-bit Wine with the i386 PE side ("new WoW64"): 32-bit Windows programs
# work without 32-bit Linux libraries.
set -euo pipefail

src=$(cd "$(dirname "$0")/.." && pwd)
version=$(sed -n 's/^Wine version //p' "$src/VERSION")
name=${1:-wine-plus-$version-amd64}
out=${OUT:-$(dirname "$src")/wine-plus-out}
jobs=${JOBS:-$(nproc)}

case $name in
  *[!A-Za-z0-9._+-]*|'') echo "invalid name: $name" >&2; exit 1 ;;
esac

mkdir -p "$out"
out=$(cd "$out" && pwd)
build=$out/build-$name
dest=$out/$name
rm -rf "$build" "$dest" "$out/$name.tar.xz"
mkdir -p "$build"

cc_flags=()
if [ "${CCACHE:-0}" = 1 ]; then
  cc_flags=(CC="ccache gcc"
            x86_64_CC="ccache x86_64-w64-mingw32-gcc"
            i386_CC="ccache i686-w64-mingw32-gcc")
fi

echo "== Configuring $name ($version)"
# configure is generated from configure.ac into the build dir, so Wine-Plus
# commits only change configure.ac (no conflicts with upstream's configure)
# and the source tree stays clean.
(cd "$src" && autoconf -o "$build/configure" && rm -rf autom4te.cache)
cd "$build"
# shellcheck disable=SC2086
./configure --srcdir="$src" --prefix="$dest" --enable-archs=i386,x86_64 --disable-tests \
  "${cc_flags[@]}" ${CONFIGURE_FLAGS:-} > configure.log 2>&1 || {
  tail -40 configure.log >&2; exit 1; }
grep -E "^configure: (WARNING|error)" configure.log || true

echo "== Building with $jobs jobs"
make -j"$jobs" > make.log 2>&1 || { tail -60 make.log >&2; exit 1; }

echo "== Installing into $dest"
make install > install.log 2>&1 || { tail -40 install.log >&2; exit 1; }
rm -rf "$dest/include" "$dest/share/man" "$dest/share/applications"

# Drop debug info (about 3/4 of the size). STRIP=0 keeps it.
if [ "${STRIP:-1}" = 1 ]; then
  echo "== Stripping debug info"
  find "$dest/bin" "$dest/lib/wine/x86_64-unix" -type f -exec sh -c \
    'file -b "$1" | grep -q "^ELF" && strip --strip-unneeded "$1"' _ {} \;
  find "$dest/lib/wine/x86_64-windows" -type f -exec x86_64-w64-mingw32-strip --strip-debug {} + 2>/dev/null || true
  find "$dest/lib/wine/i386-windows" -type f -exec i686-w64-mingw32-strip --strip-debug {} + 2>/dev/null || true
fi

# What went into this build, for the release notes and for later reference.
{
  echo "Wine-Plus $name, built $(date -u +%Y-%m-%dT%H:%MZ) from $(git -C "$src" rev-parse --short HEAD 2>/dev/null || echo unknown)."
  base=$(git -C "$src" describe --tags --abbrev=0 --match 'wine-*' 2>/dev/null || true)
  if [ -n "$base" ]; then
    echo
    echo "Based on $base with:"
    git -C "$src" log --reverse --format='- %s' "$base..HEAD" -- . ':!wine-plus' ':!.github'
  fi
} > "$dest/WINE-PLUS.txt"
cp "$dest/WINE-PLUS.txt" "$out/$name.notes.md"

echo "== Packaging $name.tar.xz"
tar -C "$out" -cf - "$name" | xz -T0 -6 > "$out/$name.tar.xz"
"$dest/bin/wine" --version
ls -l "$out/$name.tar.xz"
