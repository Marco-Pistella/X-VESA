#include "lfb_validator.h"

bool xvesa_validate_lfb_stride(uint32_t lfb_phys_base, uint16_t width, uint16_t height, uint16_t pitch, uint8_t bpp)
{
    if (lfb_phys_base == 0 || width == 0 || height == 0 || pitch == 0) {
        return false;
    }

    /* BPP must be standard 8, 15, 16, 24, or 32 */
    if (bpp != 8 && bpp != 15 && bpp != 16 && bpp != 24 && bpp != 32) {
        return false;
    }

    /* Pitch must be at least width * (bpp / 8) */
    uint32_t min_pitch = (width * bpp + 7) / 8;
    if (pitch < min_pitch) {
        return false;
    }

    /* LFB should typically be 4KB or 64KB page-aligned in 32-bit flat memory */
    if ((lfb_phys_base & 0xFFF) != 0) {
        return false;
    }

    return true;
}
