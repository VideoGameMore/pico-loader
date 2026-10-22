# DSPico QuickReturn Build 141 — test package

This build combines QuickReturn's unchanged Build 139 loader binaries with Pico Launcher Enhanced v1.10.0 by rasalopa, source commit `83e5c03ac2943916c15cb72b67e534b71a7ad017`.

## Credits

Pico Launcher and Pico Loader are by the LNH team. Enhanced menu, themes interface, save-folder support, favorites, play tracking and cheat interface improvements are by [rasalopa](https://github.com/rasalopa/pico-launcher-enhanced). QuickReturn, its integration and branded splash sequence are by Rich / VideoGameMore. This is an altered build, not an official LNH or rasalopa release.

## Changes

- Enhanced three-dot menu, favorites, recent games, statistics, screenshot controls and theme selector.
- Material and Raspberry themes included; custom theme folders go in `/_pico/themes/` and are selected in Settings.
- Saves default to a `saves` folder inside each game's folder. Existing `saveLocation` settings remain authoritative. An existing adjacent DS save is moved on first launch, unless a save already exists in the saves folder. Backup SD contents before testing.
- Cheat UI improvements retained. Database path remains `/_pico/usrcheat.dat`; press Y on a game, X in cheats disables all. No cheat database bundled.
- Existing QuickReturn L+R+Down+Select loader, QR/VGM white splash images, 44/53 frame holds and crossfade retained.
- About retains LNH and rasalopa credit and identifies QuickReturn Build 141.
- No settings file bundled, so existing user preferences are preserved.

## Validation and limits

Launcher compiled with BlocksDS 1.20.0 and libtwl submodule `aa3b2a23c10185a10449ffa685bb7933d5d5a784`. Loader parameter definitions match the Build 139 launcher byte-for-byte. Loader binaries and AP/save databases match Build 139 byte-for-byte. Runtime ZIP contains no docs/text files. Hardware testing is pending: launch, exit, relaunch, save migration/persistence, cheats and theme switching all require DS Lite checks before promoting the release. Existing compatibility results are not a claim that this launcher integration has been tested.

## Reproduce

Clone https://github.com/rasalopa/pico-launcher-enhanced and checkout `83e5c03ac2943916c15cb72b67e534b71a7ad017`; initialize its libtwl submodule. Apply `build-141.patch` with `git apply --binary`. Run `make BLOCKSDS=/opt/wonderful/thirdparty/blocksds/core WONDERFUL_TOOLCHAIN=/opt/wonderful`. Rename LAUNCHER.nds to `_picoboot.nds`, combine with the unchanged Build 139 SD package, and overlay this launcher's `_pico` theme assets. Do not overwrite the user's settings or saves.

Package: `DSPico_QuickReturn_Build_141.zip`

SHA256: `fee0983db3ca26a88ac42cfdd84d7fdc019c3deb19ed2d6a6c3dea52a0132de3`
