#pragma once

#define MEMU_DTCM_BASE  0xFFFFFF80

.struct MEMU_DTCM_BASE

memu_inst_addr:
    .word 0

memu_thumb_r0:
    .word 0

.space 8

memu_thumb_table_addr:
    .word 0
memu_arm_table_addr:
    .word 0

.previous
