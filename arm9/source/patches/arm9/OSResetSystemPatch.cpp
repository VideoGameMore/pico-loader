#include "common.h"
#include "patches/PatchContext.h"
#include "thumbInstructions.h"
#include "patches/platform/LoaderPlatform.h"
#include "OSResetSystemPatchCode.h"
#include "RetailReturnHotkeyPatchCode.h"
#include "OSResetSystemPatch.h"

static const u32 sOSResetSystemPatternSdk2Old[] = { 0xE59F101Cu, 0xE3A00010u, 0xE5815000u, 0xEB000005u };
static const u32 sOSResetSystemPatternSdk2[] = { 0xE59F1018u, 0xE3A00010u, 0xE5814000u, 0xEB000004u };
static const u32 sOSResetSystemPatternSdk2New[] = { 0xE59F1014u, 0xE3A00010u, 0xE5814000u, 0xEB000003u };
static const u32 sOSResetSystemPatternSdk3[] = { 0xE59F1014u, 0xE3A00010u, 0xE5814000u, 0xEBFFFFD9u };
static const u32 sOSResetSystemPatternSdk4[] = { 0xE59F103Cu, 0xE59F003Cu, 0xE5814000u, 0xEBFFFFD6u };
static const u32 sOSResetSystemPatternPokemonDownloader[] = { 0xE59F1010u, 0xE3A00010u, 0xE5814000u, 0xEBFFFFDEu };

static const u32 sOSResetSystemPatternSdk5Old[] = { 0xE1A04000u, 0xE1D100B0u, 0xE3500002u, 0x1A000000u };
static const u32 sOSResetSystemPatternSdk5New[] = { 0xE1A05000u, 0xE1D100B0u, 0xE3500002u, 0x1A000000u };
static const u32 sOSResetSystemPatternSdk5HybridOld[] = { 0xE1A04000u, 0xE1D100B0u, 0xE3500002u, 0x0A000006 };
static const u32 sOSResetSystemPatternSdk5HybridNew[] = { 0xE1A05000u, 0xE1D100B0u, 0xE3500002u, 0x0A000006 };

// Standard Nitro/TWL SDK IRQ dispatch tail. The first literal word immediately
// after these four instructions is the IRQ vector table address. We use the
// dispatcher only to locate that table; the dispatcher code itself is left
// completely untouched.
static const u32 sOSIrqDispatchTailPattern[] =
{
    0xE59F1008u, // ldr r1, [pc, #8]  (IRQ vector table address)
    0xE7910100u, // ldr r0, [r1, r0, lsl #2]
    0xE59FE004u, // ldr lr, [pc, #4]  (IRQ return address)
    0xE12FFF10u  // bx r0
};

bool OSResetSystemPatch::FindPatchTarget(PatchContext& patchContext)
{
    _osResetSystem = nullptr;
    _irqHandler = nullptr;
    if (patchContext.GetSdkVersion().IsTwlSdk())
    {
        _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5Old, sizeof(sOSResetSystemPatternSdk5Old));
        if (!_osResetSystem)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5New, sizeof(sOSResetSystemPatternSdk5New));
        }
        if (!_osResetSystem)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5HybridOld, sizeof(sOSResetSystemPatternSdk5HybridOld));
            _hybrid = true;
        }
        if (!_osResetSystem)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5HybridNew, sizeof(sOSResetSystemPatternSdk5HybridNew));
            _hybrid = true;
        }
    }
    else
    {
        if (patchContext.GetSdkVersion() >= 0x4017530)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk4, sizeof(sOSResetSystemPatternSdk4));
        }
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x3017530)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk3, sizeof(sOSResetSystemPatternSdk3));
        }
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x2017532)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk2New, sizeof(sOSResetSystemPatternSdk2New));
        }
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x2004F50)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk2, sizeof(sOSResetSystemPatternSdk2));
        }
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x2004EE9)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk2Old, sizeof(sOSResetSystemPatternSdk2Old));
        }
        if (!_osResetSystem)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternPokemonDownloader, sizeof(sOSResetSystemPatternPokemonDownloader));
        }
    }

    if (_osResetSystem)
    {
        LOG_DEBUG("Found end of OS_ResetSystem at %p\n", _osResetSystem);
    }
    else
    {
        LOG_DEBUG("OS_ResetSystem not found\n");
    }

    // A return hotkey is only useful when the frontend supplied a launcher path.
    if (_loaderInfo && _loaderInfo->launcherPath[0] != 0)
    {
        _irqHandler = patchContext.FindPattern32(sOSIrqDispatchTailPattern, sizeof(sOSIrqDispatchTailPattern));

        if (_irqHandler)
        {
            LOG_DEBUG("Found ARM9 IRQ vector table through dispatch tail at %p\n", _irqHandler);
        }
        else
        {
            LOG_WARNING("ARM9 IRQ dispatch tail not found; retail return hotkey disabled\n");
        }
    }

    return true;
}

void OSResetSystemPatch::ApplyPatch(PatchContext& patchContext)
{
    if (!_osResetSystem && !_irqHandler)
    {
        return;
    }

    u32 offset = 0;
    if (patchContext.GetSdkVersion().IsTwlSdk())
    {
        patch_osresetsystem_arm7Entry_address = 0x02FFFE34;
        if (_hybrid)
        {
            offset = 0x80;
            if (!_runInDSiMode)
            {
                patch_osresetsystem_entry_jump_to_twl_arm7_sync = THUMB_NOP;
            }
        }
        else
        {
            offset = 0x44;
            patch_osresetsystem_entry_jump_to_twl_arm7_sync = THUMB_NOP;
        }
    }
    else
    {
        offset = 0xC;
        patch_osresetsystem_entry_jump_to_twl_arm7_sync = THUMB_NOP;
    }

    auto loaderInfoTarget = (loader_info_t*)patchContext.GetPatchHeap().Alloc(sizeof(loader_info_t));
    memcpy(loaderInfoTarget, _loaderInfo, sizeof(loader_info_t));

    auto sdReadPatchCode = patchContext.GetLoaderPlatform()->CreateSdReadPatchCode(
        patchContext.GetPatchCodeCollection(), patchContext.GetPatchHeap());
    auto patchCodePart2 = patchContext.GetPatchCodeCollection().AddUniquePatchCode<OSResetSystemPart2PatchCode>(
        patchContext.GetPatchHeap());
    auto patchCode = patchContext.GetPatchCodeCollection().AddUniquePatchCode<OSResetSystemPatchCode>
    (
        patchContext.GetPatchHeap(),
        loaderInfoTarget,
        sdReadPatchCode,
        patchCodePart2
    );

    if (_osResetSystem)
    {
        *(u32*)((u8*)_osResetSystem + offset) = 0xE51FF004;
        *(u32*)((u8*)_osResetSystem + offset + 4) = (u32)patchCode->GetOSResetSystemFunction();
    }

    if (_irqHandler)
    {
        // The dispatch tail's first literal is the live IRQ vector table. Entry
        // zero is VBlank. Wrap only that callback and leave the dispatcher and
        // every other IRQ path untouched.
        auto irqTable = (u32*)_irqHandler[4];
        const u32 originalVBlankAddress = irqTable[0];

        if (originalVBlankAddress != 0)
        {
            auto hotkeyPatchCode = patchContext.GetPatchCodeCollection().AddUniquePatchCode<RetailReturnHotkeyPatchCode>
            (
                patchContext.GetPatchHeap(),
                (const void*)originalVBlankAddress,
                patchCode->GetReturnToLauncherFunction()
            );

            irqTable[0] = (u32)hotkeyPatchCode->GetEntryFunction();
            LOG_DEBUG("Wrapped ARM9 VBlank handler %p with retail return hotkey\n", (void*)originalVBlankAddress);
        }
        else
        {
            LOG_WARNING("ARM9 VBlank handler is null; retail return hotkey disabled\n");
        }
    }

    _cheatsPointer = patchCodePart2->GetCheatsPointerAtTarget();
}
