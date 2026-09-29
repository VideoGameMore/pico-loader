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

// Nintendo SDK ARM9 IRQ dispatcher starts. These are the same families already
// used here, but Build 49 no longer overwrites the dispatcher itself.
static const u32 sOSIrqHandlerPattern[] = { 0xE92D4000u, 0xE3A0C301u, 0xE28CCE21u, 0xE51C1008u };
static const u32 sOSIrqHandlerPatternAlt[] = { 0xE3A0C301u, 0xE28CCE21u, 0xE51C1008u, 0xE14F0000u };
static const u32 sOSIrqHandlerPatternAlt5[] = { 0xE3A0C301u, 0xE5BC2208u, 0xE1EC00D8u, 0xE3520000u };

// nds-bootstrap does not patch the dispatcher entry. It finds this tail sequence,
// reads the literal IRQ-vector-table address immediately after it, and hooks the
// first table entry (VBlank). Use the same strategy here.
static const u32 sOSIrqHandlerEndPattern[] = {
    0xE59F1008u,
    0xE7910100u,
    0xE59FE004u,
    0xE12FFF10u
};
static const u32 sOSIrqHandlerEndPatternAlt[] = {
    0xE59F100Cu,
    0xE5813000u,
    0xE5813004u,
    0xEAFFFFB8u
};

static bool Matches4(const u32* p, const u32* pattern)
{
    return p[0] == pattern[0] && p[1] == pattern[1] &&
           p[2] == pattern[2] && p[3] == pattern[3];
}

bool OSResetSystemPatch::FindPatchTarget(PatchContext& patchContext)
{
    _osResetSystem = nullptr;
    _irqHandler = nullptr;
    if (patchContext.GetSdkVersion().IsTwlSdk())
    {
        _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5Old, sizeof(sOSResetSystemPatternSdk5Old));
        if (!_osResetSystem)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5New, sizeof(sOSResetSystemPatternSdk5New));
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
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk4, sizeof(sOSResetSystemPatternSdk4));
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x3017530)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk3, sizeof(sOSResetSystemPatternSdk3));
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x2017532)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk2New, sizeof(sOSResetSystemPatternSdk2New));
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x2004F50)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk2, sizeof(sOSResetSystemPatternSdk2));
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x2004EE9)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk2Old, sizeof(sOSResetSystemPatternSdk2Old));
        if (!_osResetSystem)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternPokemonDownloader, sizeof(sOSResetSystemPatternPokemonDownloader));
    }

    if (_osResetSystem)
        LOG_DEBUG("Found end of OS_ResetSystem at %p\n", _osResetSystem);
    else
        LOG_DEBUG("OS_ResetSystem not found\n");

    if (_osResetSystem && _loaderInfo && _loaderInfo->launcherPath[0] != 0)
    {
        u32* irqStart = patchContext.FindPattern32(sOSIrqHandlerPattern, sizeof(sOSIrqHandlerPattern));
        if (!irqStart)
            irqStart = patchContext.FindPattern32(sOSIrqHandlerPatternAlt, sizeof(sOSIrqHandlerPatternAlt));
        if (!irqStart)
            irqStart = patchContext.FindPattern32(sOSIrqHandlerPatternAlt5, sizeof(sOSIrqHandlerPatternAlt5));

        if (irqStart)
        {
            // nds-bootstrap searches 50 words for the normal tail and up to
            // 0x200 words for the alternate form. Use the wider bound once.
            u32* irqEnd = nullptr;
            for (u32 i = 0; i < 0x200; i++)
            {
                u32* p = irqStart + i;
                if (Matches4(p, sOSIrqHandlerEndPattern) || Matches4(p, sOSIrqHandlerEndPatternAlt))
                {
                    irqEnd = p;
                    break;
                }
            }

            if (irqEnd)
            {
                const u32 tableAddress = irqEnd[4];
                if (tableAddress >= 0x02000000u && tableAddress < 0x03000000u && (tableAddress & 3u) == 0)
                {
                    // Reuse _irqHandler as the discovered IRQ vector-table pointer.
                    // Entry zero is the VBlank callback.
                    _irqHandler = (u32*)tableAddress;
                    LOG_DEBUG("Found ARM9 IRQ vector table at %p\n", _irqHandler);
                }
                else
                {
                    LOG_WARNING("ARM9 IRQ vector table literal invalid: %08lx\n", tableAddress);
                }
            }
        }

        if (!_irqHandler)
            LOG_WARNING("ARM9 IRQ vector table not found; retail return hotkey disabled\n");
    }

    return true;
}

void OSResetSystemPatch::ApplyPatch(PatchContext& patchContext)
{
    // Preserve the known boot-safe behavior: do nothing unless OS_ResetSystem
    // was found. Builds that allocated this path unconditionally broke boot.
    if (!_osResetSystem)
        return;

    u32 offset;
    if (patchContext.GetSdkVersion().IsTwlSdk())
    {
        patch_osresetsystem_arm7Entry_address = 0x02FFFE34;
        if (_hybrid)
        {
            offset = 0x80;
            if (!_runInDSiMode)
                patch_osresetsystem_entry_jump_to_twl_arm7_sync = THUMB_NOP;
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

    *(u32*)((u8*)_osResetSystem + offset) = 0xE51FF004;
    *(u32*)((u8*)_osResetSystem + offset + 4) = (u32)patchCode->GetOSResetSystemFunction();

    // Build 49: hook VBlank through the IRQ vector table instead of replacing
    // the dispatcher entry. This is the method used by nds-bootstrap's retail
    // card engine and avoids the dead dispatcher-entry hook from builds 37-48.
    if (_irqHandler && _irqHandler[0] != 0)
    {
        const u32 originalVBlankHandler = _irqHandler[0];
        const u32 ARM_NOP = 0xE1A00000u;

        auto hotkeyPatchCode = patchContext.GetPatchCodeCollection().AddUniquePatchCode<RetailReturnHotkeyPatchCode>
        (
            patchContext.GetPatchHeap(),
            ARM_NOP,
            ARM_NOP,
            (const void*)originalVBlankHandler,
            patchCode->GetReturnToLauncherFunction()
        );

        _irqHandler[0] = (u32)hotkeyPatchCode->GetEntryFunction();
    }

    _cheatsPointer = patchCodePart2->GetCheatsPointerAtTarget();
}
