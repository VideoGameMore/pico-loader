# DSPico QuickReturn

### Back to your games. No reboot required.

Hold **L + R + Down + Select** to return from a retail Nintendo DS game to the Pico menu on DSPico.

**[Download QuickReturn](https://github.com/VideoGameMore/pico-loader/releases/latest)** · **[Installation & full technical writeup](https://github.com/VideoGameMore/pico-loader/releases/tag/build-139)** · **[QuickReturn source](https://github.com/VideoGameMore/pico-loader/tree/feature/retail-return-hotkey)**

## Installation

**[Watch the installation video](https://www.youtube.com/watch?v=XmjKz9nq69A)** — installation starts at **4:17**, testing at **6:28**. The current package includes the QuickReturn-branded launcher.

Download **`DSPico_QuickReturn_Build_139.zip`** from the [current release](https://github.com/VideoGameMore/pico-loader/releases/latest). It contains the SD-card runtime files: the launcher, loaders, themes and databases. Documentation and source are hosted on GitHub.

### Complete SD-card setup

1. Power off and back up your microSD card, including games and saves.
2. Extract the ZIP directly to the card root, without an enclosing folder.
3. Confirm `_picoboot.nds`, `_pico/` and `nds_games/` are at the root. Put your own `.nds` games in `nds_games/`.
4. When merging into an existing installation, preserve settings, saves and BIOS files.
5. Safely eject, boot DSPico, launch a game and save. Hold **L + R + Down + Select** for about half a second to request return, then check you can launch another game.

Requires a DSPico cartridge with working firmware. Firmware flashing, games, Nintendo BIOS and NAND files are not bundled. Consult upstream instructions for files required by encrypted games or DSiWare.

### Updating an existing QuickReturn installation

Back up and replace root **`_picoboot.nds`** to install the branded launcher. The current ZIP also includes both QuickReturn loaders in `/_pico/`; install them if your setup is not already using the working QuickReturn loaders. Keep filenames and preserve your existing games, saves and settings.

The hotkey does not save progress. Some games defer a return until a supported read or gameplay transition; see the compatibility table.

## What makes QuickReturn work

- Coordinated ARM7/ARM9 return and card-ownership handoff.
- Storage-driver preservation so Pico retains access to the card.
- Split return code that fits fragmented game patch memory.
- Supported wait hooks plus a game-read return fallback.
- Optional native-reset patches that no longer block boot when memory cannot fit them.
- DMA shutdown before video-memory remapping during split takeover.

**Current tested release: Build 139.** Includes the QR-branded Pico splash and VideoGameMore splash with a crossfade. [Read the technical writeup](https://github.com/VideoGameMore/pico-loader/blob/feature/retail-return-hotkey/docs/build-139-release.md).

## Hardware testing and compatibility

**Tested on Nintendo DS Lite with DSPico.** The confirmed Build 139 test run covers 360 titles: **299 passed the launch/return/relaunch check, 57 had issues, and 4 required unavailable accessories.** One passing title, Yoshi Touch & Go, delays a pre-game return request until gameplay starts.

**[See the full compatibility table and fix/retest history](docs/compatibility.md).** The table preserves Build 139 results and will record which later build resolves each issue after hardware retesting. Passes inferred from the completed alphabetical test run are identified in the methodology. This is a return/relaunch check, not full gameplay compatibility.

Known issues include games that boot but ignore the hotkey, Contact's partial return, Animal Crossing returning to an empty Pico game list, and Pokémon Dash showing white screens at boot. DSi modes, other console models and other flashcards remain unvalidated by this run.

## Open-source foundation

QuickReturn is VideoGameMore's modified version of **[Pico Loader by LNH-team](https://github.com/LNH-team/pico-loader)**. The original loader belongs to its upstream authors and contributors; our work adds and stabilizes the DSPico retail return hotkey.

The original **Zlib license** and copyright notice are retained in [LICENSE.txt](LICENSE.txt). This fork is identified as a modified version, not the upstream release. Additional component licenses remain in [licenses](licenses).

## Source and development

The released QuickReturn implementation is on [`feature/retail-return-hotkey`](https://github.com/VideoGameMore/pico-loader/tree/feature/retail-return-hotkey), and the release tag pins the tested source. The default `develop` branch hosts this project overview and the upstream-derived base; choose the QuickReturn branch when building the hotkey version.

[Read the numbered hardware experiment log](https://github.com/VideoGameMore/pico-loader/blob/feature/retail-return-hotkey/docs/retail-return-hotkey-tests.md).

<details>
<summary>Original Pico Loader documentation and contributor credits</summary>

# Pico Loader
Pico Loader is a homebrew and retail DS(i) rom loader supporting a variety of platforms (see below).

## Features
- Supports both homebrew and retail DS(i) roms.
- Supports DSiWare and redirects NAND to the flashcard SD card (acting as "emunand", see below for how to setup).
- Supports DS roms with an encrypted secure area.
- Supports a wide range of platforms, including popular flashcards and the DSpico.
- Built-in patches for DS Protect.
- Fast loading.

> [!IMPORTANT]
> DSiWare and encrypted DS roms require a DS arm7 bios present at `/_pico/biosnds7.rom`.

Note that Pico Loader can currently not run retail roms from the DSi SD card. Homebrew is supported, however.

The upstream documentation below describes the original loader. DSPico retail return is provided by the QuickReturn release linked above.

## Supported platforms

> [!CAUTION]
> Using the wrong platform could damage your flashcard!

Note that there can be some game compatibility differences between different platforms.

| PICO_PLATFORM | Description                                                                                    | DMA |
| ------------- | ---------------------------------------------------------------------------------------------- | --- |
| ACE3DS        | Ace3DS+, Gateway 3DS (blue), r4isdhc.com.cn carts, r4isdhc.hk carts 2020+, various derivatives | ✅ |
| AK2           | Acekard 2, 2.1, 2i, r4ids.cn, various derivatives                                              | ✅ |
| AKRPG         | Acekard RPG SD card                                                                            | ✅ |
| DATEL         | DATEL devices consisting of GAMES n' MUSIC and Action Replay DS(i) Media Edition               | ❌ |
| DSPICO        | DSpico                                                                                         | ✅ |
| DSTT          | DSTT, SuperCard DSONE SDHC, r4isdhc.com carts 2014+, r4i-sdhc.com carts, various derivatives   | ✅ |
| EZP           | EZ-Flash Parallel                                                                              | ❌ |
| G003          | M3i Zero (GMP-Z003)                                                                            | ✅ |
| ISNITRO       | Supports the IS-NITRO-EMULATOR through agb semihosting.                                        | ❌ |
| M3DS          | M3 DS Real, M3i Zero, iTouchDS, r4rts.com, r4isdhc.com RTS (black)                             | ✅ |
| M3CF          | M3 Compact Flash (Slot-2 flashcart)                                                            | ❌ |
| MELONDS       | Melon DS support for testing purposes only.                                                    | ❌ |
| MMCF          | DATEL Max Media Dock Compact Flash (Slot-2 flashcart)                                          | ❌ |
| MPCF          | GBA Media Player Compact Flash (Slot-2 cart)                                                   | ❌ |
| R4            | Original R4DS (non-SDHC), M3 DS Simply                                                         | ❌ |
| R4iDSN        | r4idsn.com                                                                                     | ✅ |
| STARGATE      | Stargate 3DS DS-mode                                                                           | ✅ |
| SUPERCARD     | SuperCard SD, SuperCard Lite, SuperCard Rumble and SuperChis (Slot-2 flashcart)                | ❌ |
| SUPERCARDCF   | SuperCard CF (Slot-2 flashcart)                                                                | ❌ |

The DMA column indicates whether DMA card reads are implemented for the platform . Without DMA card reads, some games can have cache related issues.<br>
Note that there are still SDK versions and variants for which Pico Loader does not yet support DMA card reads.

## Setup & Configuration
We recommend using WSL (Windows Subsystem for Linux), or MSYS2 to compile this repository.
The steps provided will assume you already have one of those environments set up.

1. Install [BlocksDS](https://blocksds.skylyrac.net/docs/setup/)
2. Install [.NET 9.0](https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu-install?tabs=dotnet9&pivots=os-linux-ubuntu-2404) for your system (note: this link points to the instructions for Ubuntu, but links for most OS'es are available on the same page)

## Cloning
This repository includes submodules. Make sure to clone it recursively:
```
git clone --recursive https://github.com/LNH-team/pico-loader.git
```

If you cloned without initializing submodules, run the following command:
```
git submodule update --init
```

## Compiling
1. Run `make`
    - By default this compiles for the DSpico platform. To specify a different platform use `make PICO_PLATFORM=PLATFORM`, for example `make PICO_PLATFORM=R4`. See the table above for the supported platforms.
2. To use Pico Loader, create a `_pico` folder in the root of your flashcard SD card and copy the following files to it:
    - `picoLoader7.bin`
    - `picoLoader9.bin` (the version for your platform)
    - `aplist.bin` (generated in the `data` folder of the repo)
    - `savelist.bin` (generated in the `data` folder of the repo)
    - `patchlist.bin` (generated in the `data` folder of the repo)

## Emunand
When running DSiWare and DSi system apps, Pico Loader redirects NAND to the flashcard SD card. This requires the following files and folders, obtained from a DSi/3DS nand, and a DS (**not DSi**) ARM7 BIOS dump, in the root of your flashcard SD card:
- `_pico`
    - `biosnds7.rom`
- `photo` - The photo partition of nand will be redirected to this folder
- `shared1`
- `shared2`
    - `0000`
- `sys`
    - `TWLFontTable.dat`

## How to use Pico Loader from homebrew
On the arm9:
1. Map VRAM blocks A, B, C and D to LCDC
2. Load `picoLoader9.bin` to `0x06800000` (VRAM A and B)
3. Load `picoLoader7.bin` to `0x06840000` (VRAM C and D)
4. Setup the header of picoLoader7 to specify what should be loaded. See `pload_header7_t` in [include/picoLoader7.h](include/picoLoader7.h).
    - Caution: VRAM does not support byte writes!
5. Disable irqs and dma
6. Ensure the cache is flushed
7. Map VRAM C and D to arm7
8. Request the arm7 to boot into picoLoader7
    - Arm7: Disable sound, irqs and dma and jump to the `entryPoint` specified in the picoLoader7 header. Note that after mapping the VRAM to arm7, it appears at `0x06000000` on the arm7 side.
9. Arm9 jump to `0x06800000`

Note that vram must be executable on the arm9.

## License
This project is licensed under the Zlib license. For details, see `LICENSE.txt`.

Additional licenses may apply to the project. For details, see the `license` directory.

## Contributors
- [@Gericom](https://github.com/Gericom)
- [@lifehackerhansol](https://github.com/lifehackerhansol)
- [@Dartz150](https://github.com/Dartz150)
- [@XLuma](https://github.com/XLuma)
- [@edo9300](https://github.com/edo9300)
- [@Tcm0](https://github.com/Tcm0)
- [@RocketRobz](https://github.com/RocketRobz)

</details>
