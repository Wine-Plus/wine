# Wine-Plus changelog

What Wine-Plus changes compared to upstream Wine, newest release first. Every
release is upstream Wine plus all fixes that upstream doesn't have yet, so a
release contains the fixes listed under it and all earlier ones still in
effect. When upstream fixes a problem itself, the Wine-Plus fix is dropped
and noted here.

Each entry describes what users notice, the Wine component that was fixed
and the program where the problem was found. Build and CI changes are not
listed. The commits themselves are on the `plus` branch:
`git log --oneline master..plus`.

## plus-11.22

### Speech

- **Installed SAPI 5 voices can be selected and used.** Voice installers
  don't set a default voice, so on upstream Wine programs failed to select
  or use any voice. The default now comes from the user's choice, then
  the system default, then the first installed voice, as on Windows.
  (sapi, found with UltraTTS and the ScanSoft RealSpeak voices)
- **ScanSoft RealSpeak voices (and other engines that need a lexicon) no
  longer crash when speaking.** Wine now has the speech lexicon object these
  engines create. It stores no custom pronunciations, so the engines use
  their own rules. (sapi, found with RealSpeak Solo Emily and Steffi)

### Shell and file dialogs

- **Folder column captions are available to scripts and programs.**
  `Folder::GetDetailsOf()` is implemented. (shell32, found with the 64-bit
  XYplorer, which did not start)
- **No crash when opening the autocomplete list of an empty path field.**
  (shell32, found with FileLocator Pro's "Look in" field)
- **No crash while typing in autocompleting path fields after a while.**
  Wine no longer unloads the shell autocomplete DLL while it is still in
  use, which happened in MFC programs. (browseui, found with FileLocator Pro)

### Programs and controls

- **Programs that hide their menu bar no longer show an empty strip** at the
  top of the window. A menu bar without items takes no space, as on Windows.
  (win32u, found with XYplorer)
- **The WebBrowser control can be hosted in Visual Basic style containers.**
  (ieframe, found with XYplorer's preview pane)
- **Numbers like `&HFFFFFF00` convert to floating point correctly** instead
  of failing with an overflow. (oleaut32, found with the 64-bit XYplorer,
  which did not start)
- **Date formats with more than four `y`s work**, for example `yyyyy` (year
  followed by the day of the year) instead of failing. (oleaut32, found
  with XYplorer, which quit with "Run-time error '5'" when the Tools menu
  was opened)
- **Programs that link to the Extended Linguistic Services DLL start.** A stub
  `elscore.dll` reports that no language services are available, so the
  programs use their own fallbacks. (elscore, found with FileLocator Pro)
