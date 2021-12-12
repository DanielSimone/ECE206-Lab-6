//==============================================================================
// Global Defines for PUnC LC3 Computer
//==============================================================================

// Add defines here that you'll use in both the datapath and the controller

//------------------------------------------------------------------------------
// Opcodes
//------------------------------------------------------------------------------
`define OC 15:12       // Used to select opcode bits from the IR

`define OC_ADD 4'b0001 // Instruction-specific opcodes
`define OC_AND 4'b0101
`define OC_BR  4'b0000
`define OC_JMP 4'b1100
`define OC_JSR 4'b0100
`define OC_LD  4'b0010
`define OC_LDI 4'b1010
`define OC_LDR 4'b0110
`define OC_LEA 4'b1110
`define OC_NOT 4'b1001
`define OC_ST  4'b0011
`define OC_STI 4'b1011
`define OC_STR 4'b0111
`define OC_HLT 4'b1111

`define IMM_BIT_NUM 5  // Bit for distinguishing ADDR/ADDI and ANDR/ANDI
`define IS_IMM 1'b1
`define JSR_BIT_NUM 11 // Bit for distinguishing JSR/JSRR
`define IS_JSR 1'b1

`define BR_N 11        // Location of special bits in BR instruction
`define BR_Z 10
`define BR_P 9

// Multiplexor Select Inputs 
`define BASER_SR1 1'b0      // PC Counter (BASER.. , ALU_OUT_ONE)
`define PC_ALU 1'b1         // ALU A (BASER..., PC_ALU)
`define IMM5 3'd0           // ALU B (IMM5, OFFSET6, PCOFFSET9, PCOFFSET11, SR_SR2)
`define OFFSET6 3'd1        // 16 bit Comparator (Mem_OUT_ONE, ALU_OUT_ONE)
`define PCOFFSET9 3'd2      // Program Counter (BASER .. , ALU_OUT_ONE)
`define PCOFFSET11 3'd3     // Rf_w_data (PC_RF, ALU_OUT_TWO, MEM_OUT_TWO)
`define SR_SR2 3'd4         // Mem_r_addr (MEM_VALUE_TWO, INSTR_READ, ALU_OUT_TWO)
`define ALU_OUT_ONE 1'b1    // Mem_w_addr (MEM_VALUE, ALU_OUT_ONE)      
`define MEM_VALUE 1'b0      // comp_sel (MEM_OUT_ONE, ALU_OUT_ONE)
`define MEM_VALUE_TWO 2'd0      
`define MEM_OUT_ONE 1'b0 
`define PC_RF 2'd0       
`define MEM_OUT_TWO 2'd1          
`define ALU_OUT_TWO 2'd2
`define INSTR_READ 2'd1



`define ADD 2'd0          // Select ALU operation
`define AND 2'd1
`define NOT 2'd2