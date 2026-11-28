# Wine-Plus

Wine-Plus is [Wine](https://www.winehq.org) with additional fixes for Windows
programs that don't work, or don't work well, on upstream Wine. It is built
as a ready-to-use runner: 64-bit Wine with 32-bit support through new WoW64.

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

With [Q4Wine-Plus](https://github.com/Wine-Plus/q4wine):

```sh
q4wine-ctl repo add https://raw.githubusercontent.com/Wine-Plus/wine/repo/
q4wine-ctl runner install wine-plus-11.22-amd64
q4wine-ctl prefix set-runner MYPREFIX wine-plus-11.22-amd64
```

In the GUI, Wine-Plus builds appear under *Prefixes → Manage Wine runners*.
Any other launcher that uses Bottles-style runner repositories can add the
same index URL.

Without a launcher, download the `.tar.xz` from
[Releases](https://github.com/Wine-Plus/wine/releases), unpack it anywhere and
run `wine-plus-<version>-amd64/bin/wine`.

## What's fixed

The fixes are the commits on the `plus` branch that come after upstream
`master`:

```sh
git log --oneline master..plus
```

They include, for example:

- **Speech (SAPI 5):** installed voices can be selected and used. Voice installers
  don't set a default voice, so on upstream Wine programs couldn't use any voice.
  Engines such as ScanSoft RealSpeak also get the lexicon they need.
- **Shell:**
  - `Folder::GetDetailsOf()` is implemented.
  - Fixes for autocomplete in file and path fields.
- **OLE Automation:** numeric conversion fixes found with file managers such as XYplorer.
- **elscore:** a stub of the Windows language-detection DLL, so programs that load it start.

Each release lists the fixes it contains.

## Contributing

Pull requests are welcome, **including ones written with the help of LLMs or other AI tools.**
Please:

- describe the program and the problem the change fixes,
- keep each commit to one fix, in Wine's style (`module: Description.`),
- add a conformance test in `dlls/<module>/tests` where possible, and add it to
  `wine-plus/tests.txt`,
- review and test what you submit, whoever or whatever wrote it. You are
  responsible for your changes and must be able to explain them.

Wine-Plus is licensed like Wine, under the GNU LGPL 2.1 or later (see `COPYING.LIB`),
and contributions are accepted under the same license.

Maintainer documentation (branches, releases, building and testing locally) is in
[wine-plus/README.md](../wine-plus/README.md). For Wine itself, see the
[original README](../README.md).
