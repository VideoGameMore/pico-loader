# QuickReturn launcher splash builds

Build 139 is the current branded package based on [LNH-team Pico Launcher v1.3.0](https://github.com/LNH-team/pico-launcher/tree/v1.3.0). It adds the branded launcher and splash transitions. No new game compatibility fixes are claimed.

Startup: Pico + larger tilted QR (44 frames), crossfade (16 frames), VideoGameMore splash on white with www.videogamemore.com (53 frames), then menu. The 53-frame hold is approximately 20% longer than the original 44-frame hold. The sequence also runs after hotkey return. The tester confirmed the splash sequence on DS Lite at startup and after game return.

For an existing working QuickReturn setup, back up and replace only `_picoboot.nds` at the card root. Test cold boot, both splash screens, a game launch, hotkey return, populated game list and relaunch. Restore your old launcher to revert. The SD-card ZIP contains runtime files only; documentation lives here.

## Reproduce

Clone LNH-team's launcher, check out `v1.3.0` and initialize its pinned submodules. Download [build-139.patch](build-139.patch), then run `git apply --binary build-139.patch` from the launcher root. The patch includes both images and conversion settings. Build with BlocksDS 1.20.0 and the Wonderful ARM GCC toolchain. Rename `LAUNCHER.nds` to `_picoboot.nds` for DSPico.

The incoming splash uses a palette with index 255 reserved so transparent index zero can be remapped for an opaque crossfade. The binary conversion was checked to preserve all converted RGB555 pixel colors. Tile/map bounds are checked at compilation. ZIP integrity and unchanged runtime files were checked against the prior splash package.

## Attribution

The original Pico Launcher and Pico Loader are by LNH-team. This is VideoGameMore's modified version, not an official LNH-team release. Original license and component notices remain in the source projects and this fork's license documentation. Splash artwork edits were generated from the supplied logo references; assets are included in the patch.

[Original launcher](https://github.com/LNH-team/pico-launcher) · [Original loader](https://github.com/LNH-team/pico-loader) · [Build 139 compatibility table](../compatibility.md)
