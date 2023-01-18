//Spamming sounds &
//using unoptimzed custom sounds
//lead to floating point corruptions on Everdrive. Fix:

.org 0x0C55E0 //0x800C49E0
j FloatFix1
nop

.org 0x0C5734 //0x800C4B34
j FloatFix2
nop

.align 0x10
FloatFix1:
li      t9, 0x00000000 
mtc1    t9, f10   
c.eq.s  f0, f10 
nop
bc1fl   @@jumpF0 
nop     
mov.s   f0, f10
b       @@jumpF2
nop
@@jumpF0: 
c.lt.s  f0, f10   
nop
bc1fl   @@jumpOverF0Pos
nop
li      t9, 0xc6000000 
mtc1    t9, f10  
c.le.s  f0, f10  
nop
bc1fl   @@jumpOverF0Neg  
nop
mov.s   f0, f10 
b       @@jumpF2
nop
@@jumpOverF0Neg: 
li      t9, 0xbf800000   
mtc1    t9, f10     
c.le.s  f10, f0   
nop
bc1fl   @@jumpF2  
nop
li      t9, 0xbf800000    
mov.s   f0, f10
b       @@jumpF2
nop
@@jumpOverF0Pos:
li      t9, 0x46000000 
mtc1    t9, f10  
c.le.s  f10, f0 
nop
bc1fl   @@jumpOverF0Pos1  
nop
mov.s   f0, f10   
b       @@jumpF2
nop
@@jumpOverF0Pos1:
li      t9, 0x3f800000 
mtc1    t9, f10   
c.le.s  f0, f10        
nop
bc1fl   @@jumpF2  
nop
li      t9, 0x3f800000     
mov.s   f0, f10
nop
@@jumpF2:
li      t9, 0x00000000  
mtc1    t9, f10   
c.eq.s  f2, f10  
nop
bc1fl   @@jumpF2Check  
nop
mov.s   f2, f10
b       @@jumpEnd
nop
@@jumpF2Check: 
c.lt.s  f2, f10 
nop
bc1fl   @@jumpF2Pos 
nop
li      t9, 0xc6000000 
mtc1    t9, f10  
c.le.s  f2, f10  
nop
bc1fl   @@jumpOverF2Neg 
nop
mov.s   f2, f10 
b       @@jumpEnd
nop 
@@jumpOverF2Neg: 
li      t9, 0xbf800000 
mtc1    t9, f10  
c.le.s  f10, f2  
nop
bc1fl   @@jumpEnd   
nop
li      t9, 0xbf800000   
mov.s   f2, f10
b       @@jumpEnd
nop
@@jumpF2Pos:
li      t9, 0x46000000  
mtc1    t9, f10 
c.le.s  f10, f2 
nop
bc1fl   @@jumpF2Pos1  
nop
mov.s   f2, f10  
b       @@jumpEnd
nop
@@jumpF2Pos1:
li      t9, 0x3f800000 
mtc1    t9, f10  
c.le.s  f2, f10 
nop
bc1fl   @@jumpEnd 
nop
li      t9, 0x3f800000  
mov.s   f2, f10
@@jumpEnd:
nop
mul.s   f6, f0, f0
nop
mul.s   f8, f2, f2 
nop
lui     t9, 0x800f 
addiu   t9, t9, -0x5e38
j       0x800C49EC 
nop

.align 0x10
FloatFix2:
li      t9, 0xc6000000  
mtc1    t9, f6          
c.le.s  f0, f6          
nop
bc1fl   @@jumpOverF0Neg2 
nop
mov.s   f0, f6        
b       @@jumpEnd2
nop
@@jumpOverF0Neg2:
li      t9, 0xbf800000  
mtc1    t9, f6          
c.le.s  f6, f0         
nop
bc1fl   @@jumpEnd2  
nop
li      t9, 0xbf800000
mov.s   f0, f6
@@jumpEnd2:
mul.s   f6, f0, f4
nop
trunc.w.s f8, f6
move    t9, t8
j       0x800C4B3C
nop
