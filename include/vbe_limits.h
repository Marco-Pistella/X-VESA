#ifndef X_VESA_VBE_LIMITS_H
#define X_VESA_VBE_LIMITS_H

#include <stdint.h>
#include <stdbool.h>

/**
 * VESA BIOS Extensions 3.0 protected mode memory window and table limit guards.
 */

#define VBE3_MAX_PM_TABLE_SIZE  0xFFFF
#define VBE3_VALID_SEGMENT_LIMIT(seg, len) (((uint32_t)(seg) + (uint32_t)(len)) <= 0x100000)

static inline bool vbe3_validate_pm_table_bounds(uint16_t offset, uint16_t length) {
    return ((uint32_t)offset + (uint32_t)length) <= VBE3_MAX_PM_TABLE_SIZE;
}

#endif /* X_VESA_VBE_LIMITS_H */
