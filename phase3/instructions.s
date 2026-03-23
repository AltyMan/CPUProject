org 0
ldi r5, 0x43            ; R5=0x43
ldi r5, 6(r5)           ; R5=0x49
ld r4, 0x89             ; R4=(0x89)=0xA7
ldi r4, 4(r4)           ; R4=0xAB
ld r0, -8(r4)           ; R0=(0xA3)=0x68
ldi r2, 4               ; R2=4
ldi r5, 0x87            ; R5=0x87
brmi r5, 3              ; continue with the next instruction (will not branch)
ldi r5, 5(r5)           ; R5=0x8C
ld r1, -3(r5)           ; R1=(0x8C-3)=(0x89)=0xA7
nop                     ;
brpl r1, target         ; continue with the instruction at "target" (will branch)
ldi r3, 7(r5)           ; this instruction will not execute
ldi r7, -4(r3)          ; this instruction will not execute
target: add r7, r5, r2  ; R7=0x90
addi r1, r1, 3          ; R1=0xAA
neg r1, r1              ; R1=0xFFFFFF56
not r1, r1              ; R1=0xA9
andi r1, r1, 0xF        ; R1=9
ror r4, r0, r2          ; R4=0x80000006
ori r1, r4, 5           ; R1=0x80000007
shra r4, r1, r2         ; R4=0xF8000000
shr r5, r5, r2          ; R5=0x8
st 0xA3, r5             ; (0xA3)=0x8 new value in memory with address 0xA3
rol r5, r0, r2          ; R5=0x680
or r7, r2, r0           ; R7=0x6C
and r4, r5, r0          ; R4=0
st 0x89(r4), r7         ; (0x89)=0x6C new value in memory with address 0x89
sub r0, r5, r7          ; R0=0x614
shl r4, r5, r2          ; R4=0x6800
ldi r7, 7               ; R7=7
ldi r3, 0x19            ; R3=0x19
mul r3, r7              ; HI=0; LO=0xAF
mfhi r1                 ; R1=0
mflo r6                 ; R6=0xAF
div r3, r7              ; HI=4; LO=3
ldi r8, 2(r7)           ; R8=9
ldi r9, -4(r3)          ; R9=0x15
ldi r10, 3(r6)          ; R10=0xB2
ldi r11, 5(r1)          ; R11=5
jal r10                 ; address 0xB2 in R10 into PC; return address 0x29 into R12
halt                    ; upon return, the program halts

org 0xB2                ; procedure subA
subA: add r14, r8, r10  ; R14=0xBB
sub r13, r9, r11        ; R13=0x10
sub r14, r14, r13       ; R14=0xAB
jr r12                  ; return from subA procedure with address 0x29 in R12