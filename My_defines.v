`define Op_Nop   7'b0000000
`define Op_Addi  7'b0000001
`define Op_Addu  7'b0000010
`define Op_Addiu 7'b0000011
`define Op_Sub   7'b0000100
`define Op_Subu  7'b0000101
`define Op_Slt   7'b0000110
`define Op_Slti  7'b0000111
`define Op_Sltu  7'b0001000
`define Op_Sltiu 7'b0001001
`define Op_Div   7'b0001010
`define Op_Divu  7'b0001011
`define Op_Mult  7'b0001100
`define Op_Multu 7'b0001101
`define Op_Mul   7'b0001111
`define Op_Add   7'b0001110
//arithmetic inst

`define Op_And   7'b0010000
`define Op_Andi  7'b0010001
`define Op_Lui   7'b0010010
`define Op_Nor   7'b0010011
`define Op_Or    7'b0010100
`define Op_Ori   7'b0010101
`define Op_Xor   7'b0010110
`define Op_Xori  7'b0010111
//logic inst

`define Op_Sllv  7'b0100000
`define Op_Sll   7'b0100001
`define Op_Srav  7'b0100010
`define Op_Sra   7'b0100011
`define Op_Srlv  7'b0100100
`define Op_Srl   7'b0100101
//shifting inst

`define Op_Beq    7'b0110000
`define Op_Bne    7'b0110001
`define Op_Bgez   7'b0110010
`define Op_Bgtz   7'b0110011
`define Op_Blez   7'b0110100
`define Op_Bltz   7'b0110101
`define Op_Bgezal 7'b0110110
`define Op_Bltzal 7'b0110111
`define Op_J      7'b0111000
`define Op_Jal    7'b0111001
`define Op_Jr     7'b0111010
`define Op_Jalr   7'b0111011
//jump inst

`define Op_Mfhi 7'b1000000
`define Op_Mflo 7'b1000001
`define Op_Mthi 7'b1000010
`define Op_Mtlo 7'b1000011
//data movement inst

`define Op_Break   7'b1010000
`define Op_Syscall 7'b1010001
//self-trapping inst

`define Op_Lb  7'b1100000
`define Op_Lbu 7'b1100001
`define Op_Lh  7'b1100010
`define Op_Lhu 7'b1100011
`define Op_Lw  7'b1100100
`define Op_Sb  7'b1100101
`define Op_Sh  7'b1100110
`define Op_Sw  7'b1100111
//fetch inst

`define Op_Eret 7'b1110000
`define Op_Mfc0 7'b1110001
`define Op_Mtc0 7'b1110010
//privileged inst
`define Op_Teq  7'b1110011
`define Op_Tge  7'b1110100
`define Op_Tgeu 7'b1110101
`define Op_Tlt  7'b1110110
`define Op_Tltu 7'b1110111
`define Op_Tne  7'b1111000
`define Op_Teqi 7'b1111001
`define Op_Tgei 7'b1111010
`define Op_Tgeiu 7'b1111011
`define Op_Tlti  7'b1111100
`define Op_Tltiu 7'b1111101
`define Op_Tnei  7'b1111110
//trap inst

`define inst_eret 32'b01000010000000000000000000011000

`define Zero 32'b00000000
`define Enable 1'b1
`define Disable 1'b0

`define DivFree   2'b00
`define DivByZero 2'b01
`define DivOn     2'b10
`define DivEnd    2'b11
`define DivStart  1'b1
`define DivStop   1'b0

`define cp0_count 5'b01001
`define cp0_compare 5'b01011
`define cp0_status 5'b01100
`define cp0_cause 5'b01101
`define cp0_epc 5'b01110
`define cp0_prid 5'b01111
`define cp0_config 5'b10000