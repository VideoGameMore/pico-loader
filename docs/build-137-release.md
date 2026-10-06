# DSPico retail return hotkey — Build 137

Build 137 adds a hardware-tested return-to-Pico hotkey for retail Nintendo DS games on DSPico. Hold **L + R + Down + Select** for approximately half a second to request a return to the Pico menu.

This is a VideoGameMore release of a fork of **[Pico Loader by LNH-team](https://github.com/LNH-team/pico-loader)**. The original loader and its upstream contributors provide the foundation of this work; VideoGameMore's changes add and stabilize the DSPico retail return hotkey. See the upstream project for the original source, contributor credits and broader platform support. It is a **DSPico build**; the return implementation has not been validated for the other flashcard platforms supported by upstream Pico Loader.

## Installation

### Updating an existing working DSPico installation

1. Power off the console and remove its microSD card.
2. Back up the existing `picoLoader7.bin` and `picoLoader9.bin` files so you can restore your previous version.
3. Download and extract `DSPico_Build_137.zip` from this release.
4. Copy **only `picoLoader7.bin` and `picoLoader9.bin`** into the same location as those files in your current Pico installation, replacing them. Keep the filenames exactly as supplied. Do not copy the ZIP itself to the card as an installation step.
5. Leave your launcher, configuration, games, saves and existing database files in place. The included `aplist.bin`, `patchlist.bin` and `savelist.bin` are carried over from the tested package; updating these is not needed for this hotkey update.
6. Safely eject the card, put it back in DSPico and start the console.
7. Launch a game, hold **L + R + Down + Select**, and check that Pico returns. Launch another game from Pico to check your setup.

This package updates an existing DSPico/Pico installation. It does not contain a complete flashcard firmware or launcher installation, and should not be used as firmware for another flashcard.

Returning with the hotkey does not save your game progress. Save in the game before returning. The return request is serviced at a supported wait/read point; a game may need another read or a transition into gameplay before it returns. Earlier testing of Mega Man ZX showed that behavior.

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

After this change, Contra 4 returned to Pico from gameplay and from its menu. The tester then reported that every game tried from the loaded collection returned as intended. That supports the handoff-order fix; it is not proof of compatibility with every DS game.

Build 137 preserves the functional return code from Build 136 and updates the diagnostic build label only.

## Hardware results and limits

Named games reported during the test sequence include Contra 4, Pokémon Platinum, Burnout, NFS Undercover and Mega Man ZX. Contra 4 menu and gameplay return were explicitly confirmed after the Build 136 change. The final report confirmed return success across the tester's loaded collection, without an exhaustive title/region list or a per-game timing table.

Earlier builds also demonstrated a usable Pico menu and repeated game launches after return. The final broad report did not individually document repeated relaunch cycles for every title. DSi modes and other flashcard platforms are not covered by this hardware confirmation.

If reporting a problem, include Build 137, console model, game title and region, whether the hotkey was pressed at a menu or during gameplay, and whether the issue is booting, return, Pico usability or relaunch. Photograph any allocation diagnostic.

## Package and source

The release preserves the exact tested Build 137 loader binaries. `picoLoader7.bin` is the unchanged original tested ARM7 binary; the updated ARM7 detector is injected by the ARM9 patcher and is carried in `picoLoader9.bin`. The ZIP includes installation notes, this writeup and SHA-256 checksums.

Source changes and the detailed numbered experiment log are included on `feature/retail-return-hotkey`. The main implementation files are `PatchHeap`, `CardiReadCardPatch`, the split CARDi/wait assembly, `RetailHotkeyDetectionPatchCode`, `Arm9Patcher`, `Arm7Patcher` and `OSResetSystemPatch`.

ARM9 was compiled with the BlocksDS 1.20.0 toolchain environment. Built-code Unicorn checks verified wait-helper guards and state restoration, DMA shutdown before VRAM remapping only on a return request, and publication of the ARM7 request without card access before acknowledgement. These checks supplement the hardware tests; they do not simulate the complete DSPico SD protocol or both CPUs running a retail game.
