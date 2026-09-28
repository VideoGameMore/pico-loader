#pragma once
#include "../PatchCode.h"
#include "sections.h"

DEFINE_SECTION_SYMBOLS(patch_retailreturnhotkey);

extern "C" void patch_retailreturnhotkey_entry(void);

extern u32 patch_retailreturnhotkey_original_vblank_address;
extern u32 patch_retailreturnhotkey_reset_address;

class RetailReturnHotkeyPatchCode : public PatchCode
{
public:
    RetailReturnHotkeyPatchCode(PatchHeap& patchHeap, const void* originalVBlankAddress,
        const void* resetAddress)
        : PatchCode(SECTION_START(patch_retailreturnhotkey), SECTION_SIZE(patch_retailreturnhotkey), patchHeap)
    {
        patch_retailreturnhotkey_original_vblank_address = (u32)originalVBlankAddress;
        patch_retailreturnhotkey_reset_address = (u32)resetAddress;
    }

    const void* GetEntryFunction() const
    {
        return GetAddressAtTarget((void*)patch_retailreturnhotkey_entry);
    }
};
