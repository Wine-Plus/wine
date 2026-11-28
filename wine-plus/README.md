# Wine-Plus

Wine-Plus is upstream Wine plus a small set of fixes, built as a
self-contained runner (64-bit Wine with 32-bit support through new WoW64).

## Using it on a machine (Q4Wine)

Run this once per machine:

```sh
q4wine-ctl repo add https://raw.githubusercontent.com/Wine-Plus/wine/repo/
q4wine-ctl runner available plus          # list Wine-Plus builds
q4wine-ctl runner install wine-plus-11.22-amd64
q4wine-ctl prefix set-runner MYPREFIX wine-plus-11.22-amd64
```

In the Q4Wine GUI, Wine-Plus builds also show up under *Prefixes → Manage
Wine runners*, in their own group at the top of the list.

Without Q4Wine, download the `.tar.xz` from the GitHub release, unpack it
anywhere and run `wine-plus-…/bin/wine`.

## Branches

| Branch | Contents |
|---|---|
| `master` | Unchanged upstream Wine (sync it from upstream) |
| `plus` | `master` + all Wine-Plus commits (fixes + this folder + `.github/`) |
| `release/<version>` | `wine-<version>` + the Wine-Plus commits, tagged `plus-<version>` |
| `repo` | Generated runner index for Q4Wine/Bottles; don't edit it by hand |

## Adding a fix

1. Commit it on `plus`, ideally with a conformance test in `dlls/<module>/tests`.
2. Add the test to `wine-plus/tests.txt`.
3. Describe it in `wine-plus/CHANGELOG.md`, under the heading of the release it
   will be in (`## plus-<wine version>`; add the heading if it's missing). Say what
   users notice, the component and the program where it was found.
4. Push `plus`, then make a release (below).

The release notes start with the release's `CHANGELOG.md` section, followed by the
list of commits. Without a section they only list the commits. When upstream fixes a
problem itself and you drop the Wine-Plus commit, note that under the new release.

## Making a release for a Wine version

```sh
git remote add upstream https://gitlab.winehq.org/wine/wine.git   # once
wine-plus/release.sh 11.23 --push
```

`release.sh` replays the `plus` commits on `wine-11.23` and pushes the tag
`plus-11.23`. GitHub Actions then:

1. builds Wine (about 1–2 hours on GitHub's runners),
2. runs the tests in `tests.txt` for x86_64 and i386,
3. publishes the GitHub release `plus-11.23`,
4. adds `wine-plus-11.23-amd64` to the index on the `repo` branch.

If a commit no longer applies (for example, upstream fixed the same bug),
`release.sh` stops so you can resolve the conflict or skip the commit
(`git cherry-pick --skip`). To rebuild an existing tag, use *Actions →
Wine-Plus build → Run workflow*.

## Building locally

```sh
sudo wine-plus/deps-debian.sh       # Debian/Ubuntu build dependencies
wine-plus/build.sh                  # -> ../wine-plus-out/wine-plus-<ver>-amd64{,.tar.xz}
wine-plus/test.sh ../wine-plus-out/wine-plus-<ver>-amd64
```

## Keeping master in sync

Use GitHub's *Sync fork* button, or:

```sh
git fetch upstream && git push origin upstream/master:master
git switch plus && git rebase upstream/master && git push -f origin plus
```
