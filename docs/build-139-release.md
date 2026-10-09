# DSPico QuickReturn — Build 139

Hold **L + R + Down + Select** to request return from a retail DS game to the Pico menu without restarting the console.

This is **VideoGameMore's modified version** of [Pico Loader](https://github.com/LNH-team/pico-loader) and [Pico Launcher](https://github.com/LNH-team/pico-launcher), originally by **LNH-team**. Original licenses and contributor credits are retained in the repository. It is not an official LNH-team release.

**[Build 139 compatibility: 360-title DS Lite test](https://github.com/VideoGameMore/pico-loader/blob/develop/docs/compatibility.md)** · **[Project home](https://github.com/VideoGameMore/pico-loader)**

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

## Branded startup sequence

Build 139 displays the Pico Launcher berry with a larger tilted QR mark, then a white VideoGameMore splash with **www.videogamemore.com**, then the game menu. The LNH credit and website remain on the first screen. Pico holds for 44 frames, the crossfade takes 16 frames, and VGM holds for 53 frames, approximately 20% longer than Pico's hold. The sequence runs whenever the launcher starts, including after a hotkey return.

The modified launcher is based on **[LNH-team Pico Launcher v1.3.0](https://github.com/LNH-team/pico-launcher/tree/v1.3.0)**. See [launcher source and reproduction instructions](https://github.com/VideoGameMore/pico-loader/blob/develop/docs/launcher/README.md).

## Hardware results and limits

Rich / VideoGameMore tested **Build 139 on Nintendo DS Lite with DSPico**. The completed 360-title launch → hotkey return → relaunch run reports **299 passes, 57 titles with issues and 4 unable to test without accessories**. The branded splash sequence was also confirmed on hardware, including on return from a game.

**[Full Build 139 compatibility table and fix/retest history](https://github.com/VideoGameMore/pico-loader/blob/develop/docs/compatibility.md).** One passing title, Yoshi Touch & Go, delays a pre-game request until gameplay starts. Known issues comprise 54 games that boot but ignore the hotkey, Contact's partial return, Animal Crossing returning to an empty game list, and Pokémon Dash's white-screen boot failure. The boot failure has not been isolated against upstream.

Unreported titles are passes inferred from the tester's completed alphabetical run. These checks do not establish full gameplay or save compatibility, or validation on other consoles, DSi modes or other flashcards. Causes of the reported failures have not yet been diagnosed. Later fixes will be listed only after hardware retesting.

For a problem report, include build, console model, title and region/revision, where you pressed the hotkey, and whether the issue concerns boot, return, menu usability or relaunch.

## What changed and why

### Preserve the storage driver when returning

Earlier experiments reached the loader but could leave the launcher with an empty game list or partially responsive controls. The working path preserves the original DLDI storage driver and passes the launcher path and boot-drive information into the restored loader header. This allows the launcher to retain its storage access after a retail game has taken over the console.

### Use a coordinated ARM7/ARM9 handoff

ARM7 detects the button combination and publishes a return request through IPCSYNC. ARM9 acknowledges at an eligible return hook, transfers card ownership and makes staging memory available. ARM7 then reads and validates the ARM7 loader, prepares its header and enters it with a fresh processor context. ARM9 waits for the loader startup signal, loads the ARM9 loader into staging memory, checks its entry header and transfers control.

This avoids treating a retail game like homebrew that already has a usable return bootstub. It also avoids patching IRQ dispatch or interrupt vectors for the immediate return hooks.

### Fit return code into fragmented patch memory

Some games expose plenty of free patch memory overall, but only small individual blocks. One recurring diagnostic showed a largest block of 124 bytes. A larger single allocation therefore failed even when total free space was much higher.

The return path now has independently relocated pieces connected by absolute addresses. The split wait helper also uses separate 84-byte and 64-byte pieces. The allocator reserves a set of pieces atomically: either the complete set fits, or it restores the previous heap state.

A separate alignment bug was found during these experiments. Reserving each piece with insufficient padding left later ordinary allocations unaligned. Rounding the reservation to preserve four-byte alignment restored booting; that correction is retained in this build.

### Add return opportunities at supported wait sites

The patcher recognizes supported Thumb and ARM BIOS wait wrappers, including relevant relocated ARM code, and direct CP15 halt sites. Optional hooks are installed only when their code and branch constraints fit. The wait helper checks the request, processor mode and card-busy state before taking over. Normal execution restores the saved registers and flags.

Installed hooks do not prove that a particular game executes them at every menu. The read-path fallback remains, which is why return timing can differ between games.

### Stop optional native-reset patching from blocking boot

Contra 4 and Pokémon Platinum stopped with an ARM9 allocation diagnostic: 368 bytes requested, 888 bytes free in total, but a largest block of only 124 bytes. The allocation was the loader information used by the older `OS_ResetSystem` redirect.

Build 134 made that redirect optional. Its loader information and two code blocks are reserved together; if they cannot fit, the redirect is skipped and the game's native reset function is left unmodified. The independent hotkey return path remains available. This fixed the reported allocation failure and Pokémon Platinum subsequently worked.

### Stop game DMA before remapping video memory

Contra 4 then booted but could corrupt its graphics during a return attempt. Build 135 added shutdown of all four ARM9 DMA channels on the confirmed split-return acknowledgement, before remapping VRAM C/D. Normal game reads do not disable DMA.

This change alone did not fix Contra 4. It remains part of the takeover sequence, but the hardware results do not establish DMA as the original cause of the corruption.

### Request card ownership before reading the loader

The earlier ARM7 detector performed an SD loader probe before publishing the return request. That allowed loader SD reads before ARM9 acknowledged and handed over card ownership, while the game could still be using the card.

Build 136 removed that pre-request probe. ARM7 now requests the handoff first and reads the loader after acknowledgement. Full-file checksum validation and verification of the staged ARM7 payload remain in the post-ack path.

After this change, Contra 4 returned to Pico from gameplay and from its menu. The initial development collection returned as intended. That supports the handoff-order fix; it is not proof of compatibility with every DS game.

## Source and validation

QuickReturn loader implementation is on [feature/retail-return-hotkey](https://github.com/VideoGameMore/pico-loader/tree/feature/retail-return-hotkey). [Launcher patch and assets](https://github.com/VideoGameMore/pico-loader/blob/develop/docs/launcher/build-139.patch) reproduce the branded launcher from upstream v1.3.0. The development experiment log remains historical.

Compilation used BlocksDS 1.20.0. Checks covered launcher tile/map bounds, opaque crossfade pixel conversion, ZIP integrity and unchanged loader binaries. Hardware confirmation covers the splash and return flow plus the reported compatibility run; it does not establish universal compatibility.

The package version is Build 139. Embedded loader diagnostics can retain an earlier internal label; this branding update does not change the return implementation. No new game compatibility fixes are claimed.
