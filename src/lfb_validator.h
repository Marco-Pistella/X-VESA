#ifndef X_VESA_LFB_VALIDATOR_H
#define X_VESA_LFB_VALIDATOR_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Validates that linear framebuffer (LFB) physical base address, screen width,
 * bytes-per-scanline (pitch), and bits-per-pixel conform to 64KB VESA 2.0 granularity.
 */
bool xvesa_validate_lfb_stride(uint32_t lfb_phys_base, uint16_t width, uint16_t height, uint16_t pitch, uint8_t bpp);

#ifdef __cplusplus
}
#endif

#endif /* X_VESA_LFB_VALIDATOR_H */
