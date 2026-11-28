# Wine-Plus

Wine-Plus is [Wine](https://www.winehq.org) with additional fixes for Windows
programs that don't work, or don't work well, on upstream Wine. It is built
as a ready-to-use runner: 64-bit Wine with 32-bit support through new WoW64.

**[What's improved over upstream Wine →](../wine-plus/CHANGELOG.md)**

## Goals

- **Fix real programs quickly.** Wine-Plus fixes take days, not release cycles. Each fix starts
  with a specific program that fails, is traced to the Wine component at fault and is
  fixed there, so every other program that uses the component benefits too.
- **Built with the help of AI.** Wine-Plus is developed with AI coding assistants
  (currently Claude, by Anthropic). They make it possible to trace, fix and test
  problems in a code base as large as Wine at this pace.
- **Stay close to upstream.** Wine-Plus is upstream Wine plus a small set of
  separate commits. Every new Wine release is rebuilt with the Wine-Plus commits
  on top, and a fix is dropped once upstream fixes the same problem.
- **Fixes come with tests.** Wherever possible, a fix includes a conformance test
  in Wine's own test suite. The test shows the behaviour matches Windows, and
  CI runs it on every build.

## Relation to WineHQ

Wine-Plus is an independent project and is not affiliated with WineHQ.

WineHQ does not accept code written with the help of AI tools, so Wine-Plus
changes can't be submitted upstream at present, and we don't submit them.
Please don't report Wine-Plus problems to the WineHQ bug tracker or forums:
use the [issues](https://github.com/Wine-Plus/wine/issues) here instead.
If a problem also occurs with upstream Wine, report it to WineHQ as usual.

All credit for Wine itself goes to the Wine developers. Wine-Plus would not
exist without their decades of work.

## Using it

The easiest way is [Q4Wine-Plus](https://github.com/Wine-Plus/q4wine), a Wine
prefix and program manager. It installs Wine-Plus for you, so no Wine package
is needed:

1. Download the portable Q4Wine-Plus from its
   [releases](https://github.com/Wine-Plus/q4wine/releases), unpack it and run `./q4wine`.
2. In the first startup wizard, press **Download and install Wine-Plus**.

Wine-Plus then is the default Wine for your prefixes, and new Wine-Plus
releases show up in *Prefixes → Manage Wine runners*. From the command line:

```sh
q4wine-ctl runner install wine-plus --default
```

Other launchers that use Bottles-style runner repositories can add the index
`https://raw.githubusercontent.com/Wine-Plus/wine/repo/`.

Without a launcher, download the `.tar.xz` from
[Releases](https://github.com/Wine-Plus/wine/releases), unpack it anywhere and
run `wine-plus-<version>-amd64/bin/wine`.

## What's fixed

The **[changelog](../wine-plus/CHANGELOG.md)** lists every Wine-Plus fix: what it
changes for users and the program where the problem was found. Some examples:

- **Speech (SAPI 5):** installed voices can be selected and used, and engines
  such as ScanSoft RealSpeak no longer crash when speaking.
- **Shell:** `Folder::GetDetailsOf()` is implemented, and crashes in
  autocompleting path fields are fixed.
- **Programs and controls:**
  - XYplorer (64-bit) starts.
  - FileLocator Pro starts.
  - The WebBrowser control works in Visual Basic style containers.

Each release's notes list the fixes it added.

## Contributing

Pull requests are welcome, **including ones written with the help of LLMs or other AI tools.**
Please:

- describe the program and the problem the change fixes,
- keep each commit to one fix, in Wine's style (`module: Description.`),
- add a conformance test in `dlls/<module>/tests` where possible, and add it to
  `wine-plus/tests.txt`,
- add an entry to `wine-plus/CHANGELOG.md` that describes the fix from a user's point of view,
- review and test what you submit, whoever or whatever wrote it. You are
  responsible for your changes and must be able to explain them.

Wine-Plus is licensed like Wine, under the GNU LGPL 2.1 or later (see `COPYING.LIB`),
and contributions are accepted under the same license.

Maintainer documentation (branches, releases, building and testing locally) is in
[wine-plus/README.md](../wine-plus/README.md). For Wine itself, see the
[original README](../README.md).
