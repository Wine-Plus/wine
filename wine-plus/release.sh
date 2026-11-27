#!/bin/bash
# Make a Wine-Plus release of an upstream Wine version.
#
#   wine-plus/release.sh 11.22 [--push]
#
# Creates branch release/<version> from the upstream tag wine-<version>,
# replays every Wine-Plus commit (master..plus) on top and tags the result
# plus-<version>. With --push, pushes the branch, the tag and the upstream
# tag to origin, which starts the GitHub build.
#
# Remotes: origin = your GitHub repo, upstream = Wine
# (https://gitlab.winehq.org/wine/wine.git or github.com/wine-mirror/wine).
set -euo pipefail

version=${1:?usage: release.sh VERSION [--push]}
push=${2:-}
base=wine-$version
branch=release/$version
tag=plus-$version

cd "$(git rev-parse --show-toplevel)"
if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
  echo "working tree has changes; commit or stash them first" >&2; exit 1
fi

git fetch upstream "refs/tags/$base:refs/tags/$base" --no-tags
git fetch upstream master
commits=$(git rev-list --reverse --no-merges upstream/master..plus)
if [ -z "$commits" ]; then echo "no Wine-Plus commits on 'plus'" >&2; exit 1; fi

git switch -C "$branch" "$base"
# shellcheck disable=SC2086
if ! git cherry-pick $commits; then
  cat >&2 <<EOF

A Wine-Plus commit does not apply to $base. Resolve the conflict, then
  git cherry-pick --continue      (or --skip if upstream already has the fix)
and re-run: git tag -f $tag && wine-plus/release.sh $version --push
EOF
  exit 1
fi
git tag -f "$tag"
echo "Tagged $tag ($(git rev-list --count "$base..$tag") commits on top of $base)."

if [ "$push" = --push ]; then
  git push origin "refs/tags/$base"
  git push -f origin "$branch" "refs/tags/$tag"
  echo "Pushed. GitHub Actions now builds $tag; see the Actions tab."
else
  echo "Not pushed. Push with: git push origin refs/tags/$base && git push -f origin $branch refs/tags/$tag"
fi
