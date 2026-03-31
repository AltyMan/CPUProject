org 0
ldi r1, isr_handler
mtivr r1
ldi r5, 0x43
ldi r5, 6(r5)
ld r4, 0x89
ldi r4, 4(r4)
ld r0, -8(r4)
ldi r2, 4
ldi r5, 0x87
brmi r5, 3
ldi r5, 5(r5)
ld r1, -3(r5)
nop
brpl r1, target
ldi r3, 7(r5)
ldi r7, -4(r3)
target: add r7, r5, r2
addi r1, r1, 3
neg r1, r1
not r1, r1
andi r1, r1, 0xF
ror r4, r0, r2
ori r1, r4, 5
shra r4, r1, r2
shr r5, r5, r2
st 0xA3, r5
rol r5, r0, r2
or r7, r2, r0
and r4, r5, r0
st 0x89(r4), r7
sub r0, r5, r7
shl r4, r5, r2
ldi r7, 7
ldi r3, 0x19
mul r3, r7
mfhi r1
mflo r6
div r3, r7
ldi r8, 2(r7)
ldi r9, -4(r3)
ldi r10, 3(r6)
ldi r11, 5(r1)
jal r10
in r6
st 0x77, r6
ldi r3, loop 
ldi r5, 1
ldi r2, 40
ei                  

loop: 
out r6
ldi r2, -1(r2)
brzr r2, done

in r12
ldi r13, 0x0100
and r12, r12, r13
brnz r12, skip_delay

ldi r8, 0x40           
outer_loop: 
    ld r7, 0x88        
inner_loop: 
    ldi r7, -1(r7)
    nop
    brnz r7, inner_loop
    ldi r8, -1(r8)
    brnz r8, outer_loop

skip_delay:
shr r6, r6, r5
brnz r6, loop
ld r6, 0x77
jr r3

done: 
di
ldi r6, 0x63
out r6
halt

org 0x50
isr_handler:
    ldi r15, 0xEE
    out r15
    
    in r12
    ldi r13, 0x0100
    and r12, r12, r13
    brnz r12, isr_skip_delay

    ldi r15, 0x40          
isr_outer_delay: 
    ld r14, 0x88           
isr_inner_delay:
    ldi r14, -1(r14)
    nop
    brnz r14, isr_inner_delay
    
    ldi r15, -1(r15)
    brnz r15, isr_outer_delay
    
isr_skip_delay:
    in r6
    ldi r12, 0x00FF        
    and r6, r6, r12
    st 0x77, r6            
    rfi


org 0xB2
subA: 
add r14, r8, r10
sub r13, r9, r11
sub r14, r14, r13
jr r12