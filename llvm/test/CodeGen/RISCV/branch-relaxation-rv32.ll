; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs -filetype=obj < %s \
; RUN:   -o /dev/null 2>&1
; RUN: llc -mtriple=riscv32 -relocation-model=pic -verify-machineinstrs \
; RUN:   -filetype=obj < %s -o /dev/null 2>&1
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s
; RUN: llc -mtriple=riscv32 -relocation-model=pic -verify-machineinstrs < %s \
; RUN:   | FileCheck %s

define void @relax_bcc(i1 %a) nounwind {
; CHECK-LABEL: relax_bcc:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andi a0, a0, 1
; CHECK-NEXT:    bnez a0, .LBB0_1
; CHECK-NEXT:    j .LBB0_2
; CHECK-NEXT:  .LBB0_1: # %iftrue
; CHECK-NEXT:    #APP
; CHECK-NEXT:    .zero 4096
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:  .LBB0_2: # %tail
; CHECK-NEXT:    ret
  br i1 %a, label %iftrue, label %tail

iftrue:
  call void asm sideeffect ".space 4096", ""()
  br label %tail

tail:
  ret void
}

define i32 @relax_jal(i1 %a) nounwind {
; CHECK-LABEL: relax_jal:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi sp, sp, -16
; CHECK-NEXT:    andi a0, a0, 1
; CHECK-NEXT:    bnez a0, .LBB1_1
; CHECK-NEXT:  # %bb.4:
; CHECK-NEXT:    jump .LBB1_2, a0
; CHECK-NEXT:  .LBB1_1: # %iftrue
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    .zero 1048576
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    j .LBB1_3
; CHECK-NEXT:  .LBB1_2: # %jmp
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:  .LBB1_3: # %tail
; CHECK-NEXT:    li a0, 1
; CHECK-NEXT:    addi sp, sp, 16
; CHECK-NEXT:    ret
  br i1 %a, label %iftrue, label %jmp

jmp:
  call void asm sideeffect "", ""()
  br label %tail

iftrue:
  call void asm sideeffect "", ""()
  br label %space

space:
  call void asm sideeffect ".space 1048576", ""()
  br label %tail

tail:
  ret i32 1
}

define void @relax_jal_spill_32() {
; CHECK-LABEL: relax_jal_spill_32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi sp, sp, -64
; CHECK-NEXT:    .cfi_def_cfa_offset 64
; CHECK-NEXT:    sw ra, 60(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s0, 56(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s1, 52(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s2, 48(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s3, 44(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s4, 40(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s5, 36(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s6, 32(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s7, 28(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s8, 24(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s9, 20(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s10, 16(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s11, 12(sp) # 4-byte Folded Spill
; CHECK-NEXT:    .cfi_offset ra, -4
; CHECK-NEXT:    .cfi_offset s0, -8
; CHECK-NEXT:    .cfi_offset s1, -12
; CHECK-NEXT:    .cfi_offset s2, -16
; CHECK-NEXT:    .cfi_offset s3, -20
; CHECK-NEXT:    .cfi_offset s4, -24
; CHECK-NEXT:    .cfi_offset s5, -28
; CHECK-NEXT:    .cfi_offset s6, -32
; CHECK-NEXT:    .cfi_offset s7, -36
; CHECK-NEXT:    .cfi_offset s8, -40
; CHECK-NEXT:    .cfi_offset s9, -44
; CHECK-NEXT:    .cfi_offset s10, -48
; CHECK-NEXT:    .cfi_offset s11, -52
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li ra, 1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t0, 5
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t1, 6
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t2, 7
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s0, 8
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s1, 9
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a0, 10
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a1, 11
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a2, 12
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a3, 13
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a4, 14
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a5, 15
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a6, 16
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a7, 17
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s2, 18
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s3, 19
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s4, 20
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s5, 21
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s6, 22
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s7, 23
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s8, 24
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s9, 25
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s10, 26
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s11, 27
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t3, 28
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t4, 29
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t5, 30
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t6, 31
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    beq t5, t6, .LBB2_1
; CHECK-NEXT:  # %bb.3:
; CHECK-NEXT:    sw s11, 0(sp)
; CHECK-NEXT:    jump .LBB2_4, s11
; CHECK-NEXT:  .LBB2_1: # %branch_1
; CHECK-NEXT:    #APP
; CHECK-NEXT:    .zero 1048576
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    j .LBB2_2
; CHECK-NEXT:  .LBB2_4: # %branch_2
; CHECK-NEXT:    lw s11, 0(sp)
; CHECK-NEXT:  .LBB2_2: # %branch_2
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use ra
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t0
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t2
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s0
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a0
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a2
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a3
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a4
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a5
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a6
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a7
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s2
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s3
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s4
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s5
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s6
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s7
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s8
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s9
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s10
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s11
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t3
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t4
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t5
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t6
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    lw ra, 60(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s0, 56(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s1, 52(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s2, 48(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s3, 44(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s4, 40(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s5, 36(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s6, 32(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s7, 28(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s8, 24(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s9, 20(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s10, 16(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s11, 12(sp) # 4-byte Folded Reload
; CHECK-NEXT:    .cfi_restore ra
; CHECK-NEXT:    .cfi_restore s0
; CHECK-NEXT:    .cfi_restore s1
; CHECK-NEXT:    .cfi_restore s2
; CHECK-NEXT:    .cfi_restore s3
; CHECK-NEXT:    .cfi_restore s4
; CHECK-NEXT:    .cfi_restore s5
; CHECK-NEXT:    .cfi_restore s6
; CHECK-NEXT:    .cfi_restore s7
; CHECK-NEXT:    .cfi_restore s8
; CHECK-NEXT:    .cfi_restore s9
; CHECK-NEXT:    .cfi_restore s10
; CHECK-NEXT:    .cfi_restore s11
; CHECK-NEXT:    addi sp, sp, 64
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    ret
  %ra = call i32 asm sideeffect "addi ra, x0, 1", "={ra}"()
  %t0 = call i32 asm sideeffect "addi t0, x0, 5", "={t0}"()
  %t1 = call i32 asm sideeffect "addi t1, x0, 6", "={t1}"()
  %t2 = call i32 asm sideeffect "addi t2, x0, 7", "={t2}"()
  %s0 = call i32 asm sideeffect "addi s0, x0, 8", "={s0}"()
  %s1 = call i32 asm sideeffect "addi s1, x0, 9", "={s1}"()
  %a0 = call i32 asm sideeffect "addi a0, x0, 10", "={a0}"()
  %a1 = call i32 asm sideeffect "addi a1, x0, 11", "={a1}"()
  %a2 = call i32 asm sideeffect "addi a2, x0, 12", "={a2}"()
  %a3 = call i32 asm sideeffect "addi a3, x0, 13", "={a3}"()
  %a4 = call i32 asm sideeffect "addi a4, x0, 14", "={a4}"()
  %a5 = call i32 asm sideeffect "addi a5, x0, 15", "={a5}"()
  %a6 = call i32 asm sideeffect "addi a6, x0, 16", "={a6}"()
  %a7 = call i32 asm sideeffect "addi a7, x0, 17", "={a7}"()
  %s2 = call i32 asm sideeffect "addi s2, x0, 18", "={s2}"()
  %s3 = call i32 asm sideeffect "addi s3, x0, 19", "={s3}"()
  %s4 = call i32 asm sideeffect "addi s4, x0, 20", "={s4}"()
  %s5 = call i32 asm sideeffect "addi s5, x0, 21", "={s5}"()
  %s6 = call i32 asm sideeffect "addi s6, x0, 22", "={s6}"()
  %s7 = call i32 asm sideeffect "addi s7, x0, 23", "={s7}"()
  %s8 = call i32 asm sideeffect "addi s8, x0, 24", "={s8}"()
  %s9 = call i32 asm sideeffect "addi s9, x0, 25", "={s9}"()
  %s10 = call i32 asm sideeffect "addi s10, x0, 26", "={s10}"()
  %s11 = call i32 asm sideeffect "addi s11, x0, 27", "={s11}"()
  %t3 = call i32 asm sideeffect "addi t3, x0, 28", "={t3}"()
  %t4 = call i32 asm sideeffect "addi t4, x0, 29", "={t4}"()
  %t5 = call i32 asm sideeffect "addi t5, x0, 30", "={t5}"()
  %t6 = call i32 asm sideeffect "addi t6, x0, 31", "={t6}"()

  %cmp = icmp eq i32 %t5, %t6
  br i1 %cmp, label %branch_1, label %branch_2

branch_1:
  call void asm sideeffect ".space 1048576", ""()
  br label %branch_2

branch_2:
  call void asm sideeffect "# reg use $0", "{ra}"(i32 %ra)
  call void asm sideeffect "# reg use $0", "{t0}"(i32 %t0)
  call void asm sideeffect "# reg use $0", "{t1}"(i32 %t1)
  call void asm sideeffect "# reg use $0", "{t2}"(i32 %t2)
  call void asm sideeffect "# reg use $0", "{s0}"(i32 %s0)
  call void asm sideeffect "# reg use $0", "{s1}"(i32 %s1)
  call void asm sideeffect "# reg use $0", "{a0}"(i32 %a0)
  call void asm sideeffect "# reg use $0", "{a1}"(i32 %a1)
  call void asm sideeffect "# reg use $0", "{a2}"(i32 %a2)
  call void asm sideeffect "# reg use $0", "{a3}"(i32 %a3)
  call void asm sideeffect "# reg use $0", "{a4}"(i32 %a4)
  call void asm sideeffect "# reg use $0", "{a5}"(i32 %a5)
  call void asm sideeffect "# reg use $0", "{a6}"(i32 %a6)
  call void asm sideeffect "# reg use $0", "{a7}"(i32 %a7)
  call void asm sideeffect "# reg use $0", "{s2}"(i32 %s2)
  call void asm sideeffect "# reg use $0", "{s3}"(i32 %s3)
  call void asm sideeffect "# reg use $0", "{s4}"(i32 %s4)
  call void asm sideeffect "# reg use $0", "{s5}"(i32 %s5)
  call void asm sideeffect "# reg use $0", "{s6}"(i32 %s6)
  call void asm sideeffect "# reg use $0", "{s7}"(i32 %s7)
  call void asm sideeffect "# reg use $0", "{s8}"(i32 %s8)
  call void asm sideeffect "# reg use $0", "{s9}"(i32 %s9)
  call void asm sideeffect "# reg use $0", "{s10}"(i32 %s10)
  call void asm sideeffect "# reg use $0", "{s11}"(i32 %s11)
  call void asm sideeffect "# reg use $0", "{t3}"(i32 %t3)
  call void asm sideeffect "# reg use $0", "{t4}"(i32 %t4)
  call void asm sideeffect "# reg use $0", "{t5}"(i32 %t5)
  call void asm sideeffect "# reg use $0", "{t6}"(i32 %t6)

  ret void
}

define void @relax_jal_spill_32_adjust_spill_slot() {
  ; If the stack is large and the offset of BranchRelaxationScratchFrameIndex
  ; is out the range of 12-bit signed integer, check whether the spill slot is
  ; adjusted to close to the stack base register.
; CHECK-LABEL: relax_jal_spill_32_adjust_spill_slot:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi sp, sp, -2032
; CHECK-NEXT:    .cfi_def_cfa_offset 2032
; CHECK-NEXT:    sw ra, 2028(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s0, 2024(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s1, 2020(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s2, 2016(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s3, 2012(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s4, 2008(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s5, 2004(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s6, 2000(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s7, 1996(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s8, 1992(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s9, 1988(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s10, 1984(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s11, 1980(sp) # 4-byte Folded Spill
; CHECK-NEXT:    .cfi_offset ra, -4
; CHECK-NEXT:    .cfi_offset s0, -8
; CHECK-NEXT:    .cfi_offset s1, -12
; CHECK-NEXT:    .cfi_offset s2, -16
; CHECK-NEXT:    .cfi_offset s3, -20
; CHECK-NEXT:    .cfi_offset s4, -24
; CHECK-NEXT:    .cfi_offset s5, -28
; CHECK-NEXT:    .cfi_offset s6, -32
; CHECK-NEXT:    .cfi_offset s7, -36
; CHECK-NEXT:    .cfi_offset s8, -40
; CHECK-NEXT:    .cfi_offset s9, -44
; CHECK-NEXT:    .cfi_offset s10, -48
; CHECK-NEXT:    .cfi_offset s11, -52
; CHECK-NEXT:    addi s0, sp, 2032
; CHECK-NEXT:    .cfi_def_cfa s0, 0
; CHECK-NEXT:    lui a0, 2
; CHECK-NEXT:    addi a0, a0, -2032
; CHECK-NEXT:    sub sp, sp, a0
; CHECK-NEXT:    srli a0, sp, 12
; CHECK-NEXT:    slli sp, a0, 12
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li ra, 1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t0, 5
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t1, 6
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t2, 7
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s0, 8
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s1, 9
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a0, 10
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a1, 11
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a2, 12
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a3, 13
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a4, 14
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a5, 15
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a6, 16
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a7, 17
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s2, 18
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s3, 19
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s4, 20
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s5, 21
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s6, 22
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s7, 23
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s8, 24
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s9, 25
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s10, 26
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s11, 27
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t3, 28
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t4, 29
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t5, 30
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t6, 31
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    beq t5, t6, .LBB3_1
; CHECK-NEXT:  # %bb.3:
; CHECK-NEXT:    sw s11, 0(sp)
; CHECK-NEXT:    jump .LBB3_4, s11
; CHECK-NEXT:  .LBB3_1: # %branch_1
; CHECK-NEXT:    #APP
; CHECK-NEXT:    .zero 1048576
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    j .LBB3_2
; CHECK-NEXT:  .LBB3_4: # %branch_2
; CHECK-NEXT:    lw s11, 0(sp)
; CHECK-NEXT:  .LBB3_2: # %branch_2
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use ra
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t0
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t2
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s0
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a0
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a2
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a3
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a4
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a5
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a6
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a7
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s2
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s3
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s4
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s5
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s6
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s7
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s8
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s9
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s10
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s11
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t3
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t4
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t5
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t6
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    addi sp, s0, -2032
; CHECK-NEXT:    .cfi_def_cfa sp, 2032
; CHECK-NEXT:    lw ra, 2028(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s0, 2024(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s1, 2020(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s2, 2016(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s3, 2012(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s4, 2008(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s5, 2004(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s6, 2000(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s7, 1996(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s8, 1992(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s9, 1988(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s10, 1984(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s11, 1980(sp) # 4-byte Folded Reload
; CHECK-NEXT:    .cfi_restore ra
; CHECK-NEXT:    .cfi_restore s0
; CHECK-NEXT:    .cfi_restore s1
; CHECK-NEXT:    .cfi_restore s2
; CHECK-NEXT:    .cfi_restore s3
; CHECK-NEXT:    .cfi_restore s4
; CHECK-NEXT:    .cfi_restore s5
; CHECK-NEXT:    .cfi_restore s6
; CHECK-NEXT:    .cfi_restore s7
; CHECK-NEXT:    .cfi_restore s8
; CHECK-NEXT:    .cfi_restore s9
; CHECK-NEXT:    .cfi_restore s10
; CHECK-NEXT:    .cfi_restore s11
; CHECK-NEXT:    addi sp, sp, 2032
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    ret
  %stack_obj = alloca i32, align 4096

  %ra = call i32 asm sideeffect "addi ra, x0, 1", "={ra}"()
  %t0 = call i32 asm sideeffect "addi t0, x0, 5", "={t0}"()
  %t1 = call i32 asm sideeffect "addi t1, x0, 6", "={t1}"()
  %t2 = call i32 asm sideeffect "addi t2, x0, 7", "={t2}"()
  %s0 = call i32 asm sideeffect "addi s0, x0, 8", "={s0}"()
  %s1 = call i32 asm sideeffect "addi s1, x0, 9", "={s1}"()
  %a0 = call i32 asm sideeffect "addi a0, x0, 10", "={a0}"()
  %a1 = call i32 asm sideeffect "addi a1, x0, 11", "={a1}"()
  %a2 = call i32 asm sideeffect "addi a2, x0, 12", "={a2}"()
  %a3 = call i32 asm sideeffect "addi a3, x0, 13", "={a3}"()
  %a4 = call i32 asm sideeffect "addi a4, x0, 14", "={a4}"()
  %a5 = call i32 asm sideeffect "addi a5, x0, 15", "={a5}"()
  %a6 = call i32 asm sideeffect "addi a6, x0, 16", "={a6}"()
  %a7 = call i32 asm sideeffect "addi a7, x0, 17", "={a7}"()
  %s2 = call i32 asm sideeffect "addi s2, x0, 18", "={s2}"()
  %s3 = call i32 asm sideeffect "addi s3, x0, 19", "={s3}"()
  %s4 = call i32 asm sideeffect "addi s4, x0, 20", "={s4}"()
  %s5 = call i32 asm sideeffect "addi s5, x0, 21", "={s5}"()
  %s6 = call i32 asm sideeffect "addi s6, x0, 22", "={s6}"()
  %s7 = call i32 asm sideeffect "addi s7, x0, 23", "={s7}"()
  %s8 = call i32 asm sideeffect "addi s8, x0, 24", "={s8}"()
  %s9 = call i32 asm sideeffect "addi s9, x0, 25", "={s9}"()
  %s10 = call i32 asm sideeffect "addi s10, x0, 26", "={s10}"()
  %s11 = call i32 asm sideeffect "addi s11, x0, 27", "={s11}"()
  %t3 = call i32 asm sideeffect "addi t3, x0, 28", "={t3}"()
  %t4 = call i32 asm sideeffect "addi t4, x0, 29", "={t4}"()
  %t5 = call i32 asm sideeffect "addi t5, x0, 30", "={t5}"()
  %t6 = call i32 asm sideeffect "addi t6, x0, 31", "={t6}"()

  %cmp = icmp eq i32 %t5, %t6
  br i1 %cmp, label %branch_1, label %branch_2

branch_1:
  call void asm sideeffect ".space 1048576", ""()
  br label %branch_2

branch_2:
  call void asm sideeffect "# reg use $0", "{ra}"(i32 %ra)
  call void asm sideeffect "# reg use $0", "{t0}"(i32 %t0)
  call void asm sideeffect "# reg use $0", "{t1}"(i32 %t1)
  call void asm sideeffect "# reg use $0", "{t2}"(i32 %t2)
  call void asm sideeffect "# reg use $0", "{s0}"(i32 %s0)
  call void asm sideeffect "# reg use $0", "{s1}"(i32 %s1)
  call void asm sideeffect "# reg use $0", "{a0}"(i32 %a0)
  call void asm sideeffect "# reg use $0", "{a1}"(i32 %a1)
  call void asm sideeffect "# reg use $0", "{a2}"(i32 %a2)
  call void asm sideeffect "# reg use $0", "{a3}"(i32 %a3)
  call void asm sideeffect "# reg use $0", "{a4}"(i32 %a4)
  call void asm sideeffect "# reg use $0", "{a5}"(i32 %a5)
  call void asm sideeffect "# reg use $0", "{a6}"(i32 %a6)
  call void asm sideeffect "# reg use $0", "{a7}"(i32 %a7)
  call void asm sideeffect "# reg use $0", "{s2}"(i32 %s2)
  call void asm sideeffect "# reg use $0", "{s3}"(i32 %s3)
  call void asm sideeffect "# reg use $0", "{s4}"(i32 %s4)
  call void asm sideeffect "# reg use $0", "{s5}"(i32 %s5)
  call void asm sideeffect "# reg use $0", "{s6}"(i32 %s6)
  call void asm sideeffect "# reg use $0", "{s7}"(i32 %s7)
  call void asm sideeffect "# reg use $0", "{s8}"(i32 %s8)
  call void asm sideeffect "# reg use $0", "{s9}"(i32 %s9)
  call void asm sideeffect "# reg use $0", "{s10}"(i32 %s10)
  call void asm sideeffect "# reg use $0", "{s11}"(i32 %s11)
  call void asm sideeffect "# reg use $0", "{t3}"(i32 %t3)
  call void asm sideeffect "# reg use $0", "{t4}"(i32 %t4)
  call void asm sideeffect "# reg use $0", "{t5}"(i32 %t5)
  call void asm sideeffect "# reg use $0", "{t6}"(i32 %t6)

  ret void
}

define void @relax_jal_spill_32_restore_block_correspondence() {
; CHECK-LABEL: relax_jal_spill_32_restore_block_correspondence:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addi sp, sp, -64
; CHECK-NEXT:    .cfi_def_cfa_offset 64
; CHECK-NEXT:    sw ra, 60(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s0, 56(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s1, 52(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s2, 48(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s3, 44(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s4, 40(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s5, 36(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s6, 32(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s7, 28(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s8, 24(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s9, 20(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s10, 16(sp) # 4-byte Folded Spill
; CHECK-NEXT:    sw s11, 12(sp) # 4-byte Folded Spill
; CHECK-NEXT:    .cfi_offset ra, -4
; CHECK-NEXT:    .cfi_offset s0, -8
; CHECK-NEXT:    .cfi_offset s1, -12
; CHECK-NEXT:    .cfi_offset s2, -16
; CHECK-NEXT:    .cfi_offset s3, -20
; CHECK-NEXT:    .cfi_offset s4, -24
; CHECK-NEXT:    .cfi_offset s5, -28
; CHECK-NEXT:    .cfi_offset s6, -32
; CHECK-NEXT:    .cfi_offset s7, -36
; CHECK-NEXT:    .cfi_offset s8, -40
; CHECK-NEXT:    .cfi_offset s9, -44
; CHECK-NEXT:    .cfi_offset s10, -48
; CHECK-NEXT:    .cfi_offset s11, -52
; CHECK-NEXT:    .cfi_remember_state
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li ra, 1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t0, 5
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t1, 6
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t2, 7
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s0, 8
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s1, 9
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a0, 10
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a1, 11
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a2, 12
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a3, 13
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a4, 14
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a5, 15
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a6, 16
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li a7, 17
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s2, 18
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s3, 19
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s4, 20
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s5, 21
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s6, 22
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s7, 23
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s8, 24
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s9, 25
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s10, 26
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li s11, 27
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t3, 28
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t4, 29
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t5, 30
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    li t6, 31
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    bne t5, t6, .LBB4_2
; CHECK-NEXT:    j .LBB4_1
; CHECK-NEXT:  .LBB4_8: # %dest_1
; CHECK-NEXT:    lw s11, 0(sp)
; CHECK-NEXT:  .LBB4_1: # %dest_1
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # dest 1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    j .LBB4_3
; CHECK-NEXT:  .LBB4_2: # %cond_2
; CHECK-NEXT:    bne t3, t4, .LBB4_5
; CHECK-NEXT:  .LBB4_3: # %dest_2
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # dest 2
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:  .LBB4_4: # %dest_3
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # dest 3
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use ra
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t0
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t2
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s0
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a0
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a1
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a2
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a3
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a4
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a5
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a6
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use a7
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s2
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s3
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s4
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s5
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s6
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s7
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s8
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s9
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s10
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use s11
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t3
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t4
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t5
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    # reg use t6
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    lw ra, 60(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s0, 56(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s1, 52(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s2, 48(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s3, 44(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s4, 40(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s5, 36(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s6, 32(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s7, 28(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s8, 24(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s9, 20(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s10, 16(sp) # 4-byte Folded Reload
; CHECK-NEXT:    lw s11, 12(sp) # 4-byte Folded Reload
; CHECK-NEXT:    .cfi_restore ra
; CHECK-NEXT:    .cfi_restore s0
; CHECK-NEXT:    .cfi_restore s1
; CHECK-NEXT:    .cfi_restore s2
; CHECK-NEXT:    .cfi_restore s3
; CHECK-NEXT:    .cfi_restore s4
; CHECK-NEXT:    .cfi_restore s5
; CHECK-NEXT:    .cfi_restore s6
; CHECK-NEXT:    .cfi_restore s7
; CHECK-NEXT:    .cfi_restore s8
; CHECK-NEXT:    .cfi_restore s9
; CHECK-NEXT:    .cfi_restore s10
; CHECK-NEXT:    .cfi_restore s11
; CHECK-NEXT:    addi sp, sp, 64
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    ret
; CHECK-NEXT:  .LBB4_5: # %cond_3
; CHECK-NEXT:    .cfi_restore_state
; CHECK-NEXT:    beq t1, t2, .LBB4_4
; CHECK-NEXT:  # %bb.6: # %space
; CHECK-NEXT:    #APP
; CHECK-NEXT:    .zero 1048576
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:  # %bb.7: # %space
; CHECK-NEXT:    sw s11, 0(sp)
; CHECK-NEXT:    jump .LBB4_8, s11
entry:
  %ra = call i32 asm sideeffect "addi ra, x0, 1", "={ra}"()
  %t0 = call i32 asm sideeffect "addi t0, x0, 5", "={t0}"()
  %t1 = call i32 asm sideeffect "addi t1, x0, 6", "={t1}"()
  %t2 = call i32 asm sideeffect "addi t2, x0, 7", "={t2}"()
  %s0 = call i32 asm sideeffect "addi s0, x0, 8", "={s0}"()
  %s1 = call i32 asm sideeffect "addi s1, x0, 9", "={s1}"()
  %a0 = call i32 asm sideeffect "addi a0, x0, 10", "={a0}"()
  %a1 = call i32 asm sideeffect "addi a1, x0, 11", "={a1}"()
  %a2 = call i32 asm sideeffect "addi a2, x0, 12", "={a2}"()
  %a3 = call i32 asm sideeffect "addi a3, x0, 13", "={a3}"()
  %a4 = call i32 asm sideeffect "addi a4, x0, 14", "={a4}"()
  %a5 = call i32 asm sideeffect "addi a5, x0, 15", "={a5}"()
  %a6 = call i32 asm sideeffect "addi a6, x0, 16", "={a6}"()
  %a7 = call i32 asm sideeffect "addi a7, x0, 17", "={a7}"()
  %s2 = call i32 asm sideeffect "addi s2, x0, 18", "={s2}"()
  %s3 = call i32 asm sideeffect "addi s3, x0, 19", "={s3}"()
  %s4 = call i32 asm sideeffect "addi s4, x0, 20", "={s4}"()
  %s5 = call i32 asm sideeffect "addi s5, x0, 21", "={s5}"()
  %s6 = call i32 asm sideeffect "addi s6, x0, 22", "={s6}"()
  %s7 = call i32 asm sideeffect "addi s7, x0, 23", "={s7}"()
  %s8 = call i32 asm sideeffect "addi s8, x0, 24", "={s8}"()
  %s9 = call i32 asm sideeffect "addi s9, x0, 25", "={s9}"()
  %s10 = call i32 asm sideeffect "addi s10, x0, 26", "={s10}"()
  %s11 = call i32 asm sideeffect "addi s11, x0, 27", "={s11}"()
  %t3 = call i32 asm sideeffect "addi t3, x0, 28", "={t3}"()
  %t4 = call i32 asm sideeffect "addi t4, x0, 29", "={t4}"()
  %t5 = call i32 asm sideeffect "addi t5, x0, 30", "={t5}"()
  %t6 = call i32 asm sideeffect "addi t6, x0, 31", "={t6}"()

  br label %cond_1

cond_1:
  %cmp1 = icmp eq i32 %t5, %t6
  br i1 %cmp1, label %dest_1, label %cond_2

cond_2:
  %cmp2 = icmp eq i32 %t3, %t4
  br i1 %cmp2, label %dest_2, label %cond_3

cond_3:
  %cmp3 = icmp eq i32 %t1, %t2
  br i1 %cmp3, label %dest_3, label %space

space:
  call void asm sideeffect ".space 1048576", ""()
  br label %dest_1

dest_1:
  call void asm sideeffect "# dest 1", ""()
  br label %dest_2

dest_2:
  call void asm sideeffect "# dest 2", ""()
  br label %dest_3

dest_3:
  call void asm sideeffect "# dest 3", ""()
  br label %tail

tail:
  call void asm sideeffect "# reg use $0", "{ra}"(i32 %ra)
  call void asm sideeffect "# reg use $0", "{t0}"(i32 %t0)
  call void asm sideeffect "# reg use $0", "{t1}"(i32 %t1)
  call void asm sideeffect "# reg use $0", "{t2}"(i32 %t2)
  call void asm sideeffect "# reg use $0", "{s0}"(i32 %s0)
  call void asm sideeffect "# reg use $0", "{s1}"(i32 %s1)
  call void asm sideeffect "# reg use $0", "{a0}"(i32 %a0)
  call void asm sideeffect "# reg use $0", "{a1}"(i32 %a1)
  call void asm sideeffect "# reg use $0", "{a2}"(i32 %a2)
  call void asm sideeffect "# reg use $0", "{a3}"(i32 %a3)
  call void asm sideeffect "# reg use $0", "{a4}"(i32 %a4)
  call void asm sideeffect "# reg use $0", "{a5}"(i32 %a5)
  call void asm sideeffect "# reg use $0", "{a6}"(i32 %a6)
  call void asm sideeffect "# reg use $0", "{a7}"(i32 %a7)
  call void asm sideeffect "# reg use $0", "{s2}"(i32 %s2)
  call void asm sideeffect "# reg use $0", "{s3}"(i32 %s3)
  call void asm sideeffect "# reg use $0", "{s4}"(i32 %s4)
  call void asm sideeffect "# reg use $0", "{s5}"(i32 %s5)
  call void asm sideeffect "# reg use $0", "{s6}"(i32 %s6)
  call void asm sideeffect "# reg use $0", "{s7}"(i32 %s7)
  call void asm sideeffect "# reg use $0", "{s8}"(i32 %s8)
  call void asm sideeffect "# reg use $0", "{s9}"(i32 %s9)
  call void asm sideeffect "# reg use $0", "{s10}"(i32 %s10)
  call void asm sideeffect "# reg use $0", "{s11}"(i32 %s11)
  call void asm sideeffect "# reg use $0", "{t3}"(i32 %t3)
  call void asm sideeffect "# reg use $0", "{t4}"(i32 %t4)
  call void asm sideeffect "# reg use $0", "{t5}"(i32 %t5)
  call void asm sideeffect "# reg use $0", "{t6}"(i32 %t6)

  ret void
}

