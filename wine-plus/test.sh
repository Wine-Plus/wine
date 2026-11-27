#!/bin/bash
# Run the conformance tests listed in wine-plus/tests.txt against a built
# Wine-Plus runner, for both x86_64 and i386.
#
#   wine-plus/test.sh RUNNER_DIR
#
# The test programs are built from this tree in a separate, minimal build
# (tools + the listed tests only). Without $DISPLAY, xvfb-run is used.
set -euo pipefail

src=$(cd "$(dirname "$0")/.." && pwd)
runner=$(cd "${1:?usage: test.sh RUNNER_DIR}" && pwd)
out=${OUT:-$(dirname "$src")/wine-plus-out}
mkdir -p "$out"
out=$(cd "$out" && pwd)
jobs=${JOBS:-$(nproc)}
build=$out/build-tests

mapfile -t tests < <(grep -vE '^\s*(#|$)' "$src/wine-plus/tests.txt")
targets=()
for t in "${tests[@]}"; do
  read -r mod _ <<< "$t"
  for arch in x86_64 i386; do targets+=("dlls/$mod/tests/$arch-windows/${mod}_test.exe"); done
done

if [ ! -f "$build/Makefile" ]; then
  echo "== Configuring test build"
  mkdir -p "$build"
  (cd "$build" && "$src/configure" --enable-archs=i386,x86_64 --without-x --without-freetype \
     --without-wayland --without-gstreamer --without-vulkan --without-opengl > configure.log 2>&1) || {
    tail -40 "$build/configure.log" >&2; exit 1; }
fi
echo "== Building ${#targets[@]} test programs"
make -C "$build" -j"$jobs" "${targets[@]}" > "$build/make.log" 2>&1 || {
  tail -40 "$build/make.log" >&2; exit 1; }

# Gecko is needed by the ieframe/mshtml tests; a cached MSI is installed
# without asking.
gecko=$(sed -n 's/^#define GECKO_VERSION "\(.*\)"/\1/p' "$src/dlls/appwiz.cpl/addons.c")
cache=${XDG_CACHE_HOME:-$HOME/.cache}/wine
mkdir -p "$cache"
for a in x86 x86_64; do
  f=wine-gecko-$gecko-$a.msi
  [ -s "$cache/$f" ] || curl -fsSL -o "$cache/$f" "https://dl.winehq.org/wine/wine-gecko/$gecko/$f"
done

export WINEPREFIX=$out/test-prefix WINEDEBUG=-all WINEDLLOVERRIDES="mscoree=d"
rm -rf "$WINEPREFIX"
run=()
[ -z "${DISPLAY:-}" ] && run=(xvfb-run -a -s "-screen 0 1280x1024x24")

"${run[@]}" "$runner/bin/wineboot" -i > /dev/null 2>&1
"$runner/bin/wineserver" -w

failed=0
for t in "${tests[@]}"; do
  read -r mod name <<< "$t"
  for arch in x86_64 i386; do
    exe=$build/dlls/$mod/tests/$arch-windows/${mod}_test.exe
    log=$out/test-$mod-$name-$arch.log
    timeout 900 "${run[@]}" "$runner/bin/wine" "$exe" "$name" > "$log" 2>&1 || true
    summary=$(grep -a "tests executed" "$log" | tail -1 | sed 's/^[0-9a-f]*://')
    if [[ $summary == *" 0 failures"* ]]; then
      echo "PASS  $mod:$name ($arch)  $summary"
    else
      echo "FAIL  $mod:$name ($arch)  ${summary:-no summary, see $log}"
      grep -a "Test failed" "$log" | head -20 | sed 's/^/      /'
      failed=1
    fi
  done
done
"$runner/bin/wineserver" -k || true
exit $failed
