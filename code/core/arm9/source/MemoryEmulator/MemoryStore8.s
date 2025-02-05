.section ".itcm", "ax"

#include "AsmMacros.inc"
#include "GbaIoRegOffsets.h"

/// @brief Stores an 8-bit value to the given GBA memory address.
/// @param r0-r7 Preserved.
/// @param r8 The address to store to. This register is preserved.
/// @param r9 The value to store. Must be 8-bit masked: 0x000000XX. Trashed.
/// @param r10-r12 Trashed.
/// @param r13 Preserved.
/// @param lr Return address.
arm_func memu_store8
    cmp r8, #0x10000000
        ldrlo pc, [pc, r8, lsr #22]
    bx lr

    .word memu_store8Bios // 00
    .word memu_store8Undefined // 01
    .word memu_store8Ewram // 02
    .word memu_store8Iwram // 03
    .word memu_store8Io // 04
    .word memu_store8Pltt // 05
    .word memu_store8Vram // 06
    .word memu_store8Undefined // 07, byte writes to oam are ignored
    .word memu_store8Rom // 08
    .word memu_store8Rom // 09
    .word memu_store8Rom // 0A
    .word memu_store8Rom // 0B
    .word memu_store8Rom // 0C
    .word memu_store8Rom // 0D
    .word memu_store8Sram // 0E
    .word memu_store8Sram // 0F

arm_func memu_store8Undefined
    bx lr

arm_func memu_store8Bios
    cmp r8, #0x4000
        bxhs lr
    bx lr

arm_func memu_store8Ewram
    bic r10, r8, #0x00FC0000
    strb r9, [r10]
    bx lr

arm_func memu_store8Iwram
    bic r10, r8, #0x00FF0000
    bic r10, r10, #0x00008000
    strb r9, [r10]
    bx lr

arm_func memu_store8Io
    ldr r12,= emu_ioRegisters
    ldr r11,= memu_store16IoTable
    sub r10, r8, #0x04000000
    ldrh r11, [r11, r10]
    tst r8, #1
    ldrh r12, [r12, r10]
        bne memu_store8IoHi
    cmp r10, #0x20C
        biclo r12, r12, #0xFF
        orrlo r9, r12, r9
        bxlo r11
    // todo: postflag
    bx lr

arm_func memu_store8IoHi
    cmp r10, #0x20C
        biclo r12, r12, #0xFF00
        orrlo r9, r12, r9, lsl #8
        bxlo r11
    mov r11, #0x300
    orr r11, r11, #1
    cmp r10, r11
        beq haltcnt
    bx lr

haltcnt:
    cmp r9, #0
        mcreq p15, 0, r9, c7, c0, 4
    bx lr

arm_func memu_store8Pltt
    orr r9, r9, r9, lsl #8
    bic r10, r8, #0x00FF0000
    bic r10, r10, #0x0000FC00
    strh r9, [r10]
    bx lr

arm_func memu_store8Vram
    ldr r11,= emu_ioRegisters
    bic r10, r8, #0x00FE0000
    ldrh r11, [r11, #GBA_REG_OFFS_DISPCNT]
    ldr r12,= 0x06018000
    cmp r10, r12
        bicge r10, #0x8000

    and r12, r11, #7
    cmp r12, #3
        ldrlt r11,= 0x06010000
        ldrge r11,= 0x06014000
    cmp r10, r11
        bxge lr // 8 bit writes ignored in obj vram
    orr r9, r9, r9, lsl #8
    strh r9, [r10]
    bx lr

arm_func memu_store8Rom
    bx lr

arm_func memu_store8Sram
    bx lr