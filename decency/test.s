mv $0, 0
nop
mv $3, 1
nop
bgt $0, $3, L1
nop
L2: 
mv $1, 0
nop
mv $4, 2
nop
bgt $1, $4, L3
nop
L4: 
mul $5, $0, 3
mul $6, $1, 2
mul $7, $0, 2
mv $8, 0
mv $9, 6
mv $10, 12
nop
lw $11, $5, $1
add $9, $9, $6
add $10, $10, $7
nop
lw $12, $9, 0
lw $13, $9, 4
nop
mul $12, $12, $11
mul $13, $13, $11
nop
lw $38, $10, 0
lw $39, $10, 4
nop
add $12, $12, $38
add $13, $13, $39
nop
sw $38, $10, 0
sw $39, $10, 4
nop
add $1, $1, 1
nop
bgt $1, $4, L3
nop
j L4
nop
L3: 
add $0, $0, 1
nop
bgt $0, $3, L1
nop
j L2
nop
L1: 
nop
