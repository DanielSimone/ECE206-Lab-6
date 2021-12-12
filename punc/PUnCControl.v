//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCControl#(parameter DATA_WIDTH = 16)(
	// External Inputs
	input  wire         clk,            // Clock
	input  wire         rst,            // Reset
	// input  wire 		external_instruction this is obtained from the memory unit of the data path

	// Inputs from datapath predicates
	//input 				PC_data, not necessary since the instruction is fetched in the datapath
	input 				[15:0] IR_data,
	//input 				bit_equal, 		// Unecessary
	input 				Zed,
	input 				N,
	input 				P,

	// Outputs to datapath
	// MUX and ALU Control signals
	output reg 			[1:0] rf_w_data_sel,
	output reg 			Mem_w_addr_sel,
	output reg 			[1:0] Mem_r_addr_sel, 
	output reg 			PC_sel,
	output reg 			ALU_A_sel,
	output reg 			[2:0] ALU_B_sel,
	output reg 			[1:0] ALU_op,
	output reg 			comp_sel,
	
	// RegFile Control Signals
	// Specify DR, Rf1:(BaseR, R7, SR1) and Rf2:(SR, SR2) with the corresponding port on Regfile for clarity
	output reg 			[2:0] dr_w_data,
	output reg 			rf_w_en,
	output reg 			[2:0] Rf1_addr_0,
	output reg 			[2:0] Rf2_addr_1,
	
	// Memory Control Signals
	output reg 			mem_ld,

	// Memory Value Control
	output reg 			mem_val_ld,
	
	//PC Control Signals 
	output reg 			PC_ld,
	output reg 			PC_cnt,

	//Instruction Register (IR) Control Signals
	output reg 			IR_ld,
	// output reg 			[(DATA_WIDTH - 1):0] instruction, Not needed since IR_data

	//Instruction Specific Constants
	output reg 			bit_in, // Can be eliminated
	output reg 			[4:0] imm5,
	output reg 			[5:0] offset6,
	output reg 			[8:0] PCoffset9,
	output reg 			[10:0] PCoffset11,

	// Set the Condition Code
	output reg 			setcc

);

	// FSM States
	// Add your FSM State values as localparams here
	localparam STATE_FETCH     = 5'd0;
	localparam STATE_DECODE	   = 5'd1;
	localparam STATE_ADD1      = 5'd2;
	localparam STATE_ADD2      = 5'd3;
	localparam STATE_ADD3      = 5'd4;
	localparam STATE_AND1      = 5'd5;
	localparam STATE_AND2      = 5'd6;
	localparam STATE_AND3      = 5'd7;
	localparam STATE_BR1   	   = 5'd8;
	localparam STATE_BR2   	   = 5'd9;
	localparam STATE_JMP   	   = 5'd10;
	localparam STATE_JS 	   = 5'd11;
	localparam STATE_JSR       = 5'd12;
	localparam STATE_JSRR      = 5'd13;
	localparam STATE_LD   	   = 5'd14;
	localparam STATE_LDI1      = 5'd15;
	localparam STATE_LDI2      = 5'd16;
	localparam STATE_LDR   	   = 5'd17;
	localparam STATE_LEA   	   = 5'd18;
	localparam STATE_NOT   	   = 5'd19;
	// localparam STATE_RET   	   = 5'd20; Irrelevant Because RET is exact same opcode for jump just more specified write register
	localparam STATE_ST   	   = 5'd21;
	localparam STATE_STI1      = 5'd22;
	localparam STATE_STI2      = 5'd23;
	localparam STATE_STR   	   = 5'd24;
	localparam STATE_HALT      = 5'd25;

	// State, Next State
	reg [4:0] state, next_state;

	// Output Combinational Logic
	always @( * ) begin
		// Set default values for outputs here (prevents implicit latching)

		// Outputs to datapath
		// MUX and ALU Control signals
		rf_w_data_sel 		= 2'd0;
		Mem_w_addr_sel		= 0;
		Mem_r_addr_sel		= 0;
		PC_sel				= 0;
		ALU_A_sel			= 0;
		ALU_B_sel			= 3'd0;
		ALU_op				= 2'd0;
		comp_sel			= 0;
		
		// RegFile Control Signals
		// Specify DR, Rf1:(BaseR, R7, SR1) and Rf2:(SR, SR2) with the corresponding port on Regfile for clarity
		dr_w_data	    	= 3'd0;
		rf_w_en				= 0;
		Rf1_addr_0			= 3'd0;
		Rf2_addr_1			= 3'd0;
		
		// Memory Control Signals
		mem_ld				= 0;

		// Memory Value Control
		mem_val_ld			= 0;
		
		//PC Control Signals 
		PC_ld				= 0;
		PC_cnt				= 0;

		//Instruction Register (IR) Control Signals
		IR_ld				= 0;
		//instruction			= 16'd0; // Could not use DATA_WIDTH :(

		//Instruction Specific Constants
		bit_in				= 0;
		imm5				= 5'd0;
		offset6				= 6'd0;
		PCoffset9			= 9'd0;
		PCoffset11			= 11'd0;

		// Set the Condition Code
		setcc				= 0;

		// Based on: https://docs.google.com/spreadsheets/d/1Lhxl_D5ZHBfNlg01y17G5V7o_PJj3K1bexPPkI_vfI0/edit#gid=0
		// Add your output logic here
		case (state)
			STATE_FETCH: begin
				IR_ld = 1;
				PC_cnt = 1;
				Mem_r_addr_sel = `INSTR_READ;
			end
			STATE_DECODE: begin
				//rf_w_en = 1;
			end
			STATE_ADD1: begin	   	// Honestly this is unecessary if we don't use the comparator
				bit_in = IR_data[5];// Unecessary
			end
			STATE_ADD2: begin
				rf_w_en = 1;
				setcc = 1; 
				dr_w_data = IR_data[11:9];
				Rf1_addr_0 = IR_data[8:6];
				Rf2_addr_1 = IR_data[2:0];
				bit_in = IR_data[`IMM_BIT_NUM]; // Unecessary
				rf_w_data_sel =`ALU_OUT_TWO;
				ALU_A_sel = `BASER_SR1; // SR1
				ALU_B_sel = `SR_SR2; // SR2
				ALU_op = `ADD;
				comp_sel = `ALU_OUT_ONE;
			end
			STATE_ADD3: begin
				rf_w_en = 1;
				setcc = 1;
				dr_w_data = IR_data[11:9];
				Rf1_addr_0 = IR_data[8:6];
				bit_in = 1; // Unecessary
				imm5 = IR_data[4:0];
				rf_w_data_sel =`ALU_OUT_TWO;
				ALU_A_sel = `BASER_SR1; // SR1
				ALU_B_sel = `IMM5; // imm5
				ALU_op = `ADD;
				comp_sel = `ALU_OUT_ONE;
			end
			STATE_AND1: begin		// This also becomes unecessary
				bit_in = IR_data[5]; // Unecessary
			end
			STATE_AND2: begin
				rf_w_en = 1;
				setcc = 1;
				dr_w_data = IR_data[11:9];
				Rf1_addr_0 = IR_data[8:6];
				Rf2_addr_1 = IR_data[2:0];
				rf_w_data_sel =`ALU_OUT_TWO;
				ALU_A_sel = `BASER_SR1; // SR1
				ALU_B_sel = `SR_SR2; // SR2
				ALU_op = `AND;
				comp_sel = `ALU_OUT_ONE;
			end
			STATE_AND3: begin
				rf_w_en = 1;
				setcc = 1;
				dr_w_data = IR_data[11:9];
				Rf1_addr_0 = IR_data[8:6];
				imm5 = IR_data[4:0];
				rf_w_data_sel =`ALU_OUT_TWO;
				ALU_A_sel = `BASER_SR1; // SR1
				ALU_B_sel = `IMM5; // imm5
				ALU_op = `AND;	
				comp_sel = `ALU_OUT_ONE;
			end
			STATE_BR1: begin
			end
			STATE_BR2: begin
				PCoffset9 = IR_data[8:0];
				PC_ld = 1;
				PC_sel = `ALU_OUT_ONE; //ALU_out
				ALU_A_sel = `PC_ALU; //PC
				ALU_B_sel = `PCOFFSET9; //SEXT(PCoffset9)
				ALU_op = `ADD;
			end
			STATE_JMP: begin
				PC_ld = 1;
				Rf1_addr_0 = IR_data[8:6];
				PC_sel = `BASER_SR1;
			end
			STATE_JS: begin
				rf_w_en = 1;
				dr_w_data = 3'd7;
				bit_in = IR_data[11]; //Unecessary
			end
			STATE_JSR: begin
				PC_ld = 1; 
				PC_sel = `ALU_OUT_ONE; //ALU_out
				ALU_A_sel = `PC_ALU; //PC
				ALU_B_sel = `PCOFFSET11; //SEXT(PCoffset11)
				PCoffset11 = IR_data[10:0];
				ALU_op = `ADD;
			end
			STATE_JSRR: begin
				PC_ld = 1;
				Rf1_addr_0 = IR_data[8:6];
				PC_sel = `BASER_SR1; //BaseR
			end
			STATE_LD: begin
				rf_w_en = 1;
				setcc = 1;
				dr_w_data = IR_data[11:9];
				PCoffset9 = IR_data[8:0];
				Mem_r_addr_sel = `ALU_OUT_TWO; //ALU_out
				rf_w_data_sel = `MEM_OUT_TWO; //mem_out
				ALU_A_sel = `PC_ALU; //PC
				ALU_B_sel = `PCOFFSET9; //SEXT(PCoffset9)
				ALU_op = `ADD;
				comp_sel = `MEM_OUT_ONE;	
			end
			STATE_LDI1: begin
				mem_val_ld = 1;
				PCoffset9 = IR_data[8:0];
				Mem_r_addr_sel = `ALU_OUT_TWO; //ALU_out
				ALU_A_sel = `PC_ALU; //PC
				ALU_B_sel = `PCOFFSET9; //SEXT(PCoffset9)
				ALU_op = `ADD;
				comp_sel = `MEM_OUT_ONE;
			end
			STATE_LDI2: begin
				rf_w_en = 1;
				setcc = 1;
				dr_w_data = IR_data[11:9];
				Mem_r_addr_sel = `MEM_VALUE_TWO; //mem_value
				rf_w_data_sel = `MEM_OUT_TWO; //mem_out
				comp_sel = `MEM_OUT_ONE;	
			end
			STATE_LDR: begin
				rf_w_en = 1;
				setcc = 1;
				dr_w_data = IR_data[11:9];
				Rf1_addr_0 = IR_data[8:6];
				offset6 = IR_data[5:0];
				Mem_r_addr_sel = `ALU_OUT_TWO; //ALU_out
				rf_w_data_sel = `MEM_OUT_TWO; //mem_out
				ALU_A_sel = `BASER_SR1; //BaseR
				ALU_B_sel = `OFFSET6; //SEXT(offset6)
				ALU_op = `ADD;
				comp_sel = `MEM_OUT_ONE;	
			end
			STATE_LEA: begin
				rf_w_en = 1;
				setcc = 1;
				dr_w_data = IR_data[11:9];
				PCoffset9 = IR_data[8:0];
				rf_w_data_sel = `ALU_OUT_TWO; //ALU_out
				ALU_A_sel = `PC_ALU; //PC
				ALU_B_sel = `PCOFFSET9; //SEXT(PCoffset9)
				ALU_op = `ADD;
				comp_sel = `MEM_OUT_ONE;	
			end
			STATE_NOT: begin
				rf_w_en = 1;
				setcc = 1;
				dr_w_data = IR_data[11:9];
				Rf2_addr_1 = IR_data[8:6];
				rf_w_data_sel = `ALU_OUT_TWO; //ALU_out
				ALU_B_sel = `SR_SR2; //SR
				ALU_op = `NOT;
				comp_sel = `ALU_OUT_ONE;	
			end
			//STATE_RET: begin RET is just the same as the JUMP command
				//PC_ld = 1;
				//PC_sel = ???; //R7
			//end
			STATE_ST: begin
				mem_ld = 1;
				Rf2_addr_1 = IR_data[11:9];
				PCoffset9 = IR_data[8:0];
				Mem_w_addr_sel = `ALU_OUT_ONE; //ALU_out
				ALU_A_sel = `PC_ALU; //PC
				ALU_B_sel = `PCOFFSET9; //SEXT(PCoffset9)
				ALU_op = `ADD;
					
			end
			STATE_STI1: begin
				mem_val_ld = 1;
				PCoffset9 = IR_data[8:0];
				Mem_r_addr_sel = `ALU_OUT_TWO; //ALU_out
				ALU_A_sel = `PC_ALU; //PC
				ALU_B_sel = `PCOFFSET9; //SEXT(PCoffset9)
				ALU_op = `ADD;
			end
			STATE_STI2: begin
				mem_ld = 1;
				Rf2_addr_1 = IR_data[11:9];
				Mem_w_addr_sel = `MEM_VALUE; //Mem_value
			end
			STATE_STR: begin
				mem_ld = 1;
				Rf1_addr_0 = IR_data[8:6];
				Rf2_addr_1 = IR_data[11:9];
				offset6 = IR_data[5:0];
				Mem_w_addr_sel = `ALU_OUT_ONE; //ALU_out
				ALU_A_sel = `BASER_SR1; //BaseR
				ALU_B_sel = `OFFSET6; //SEXT(offset6)
			end
			STATE_HALT: begin
				//Loops and sets all variables to zero
			end
		endcase
	end

	// Next State Combinational Logic
	always @( * ) begin
		// Set default value for next state here
		next_state = state;
		
		// Add your next-state logic here
		case (state)
			STATE_FETCH:	next_state 									= STATE_DECODE;
			STATE_DECODE:	begin
				if (IR_data[`OC] == `OC_ADD) next_state 				= STATE_ADD1;
				else if (IR_data[`OC] == `OC_AND) next_state 			= STATE_AND1;
				else if (IR_data[`OC] == `OC_BR) next_state 			= STATE_BR1;
				else if (IR_data[`OC] == `OC_JMP) next_state 			= STATE_JMP;
				else if (IR_data[`OC] == `OC_JSR) next_state 			= STATE_JS;
				else if (IR_data[`OC] == `OC_LD) next_state 			= STATE_LD;
				else if (IR_data[`OC] == `OC_LDI) next_state 			= STATE_LDI1;
				else if (IR_data[`OC] == `OC_LDR) next_state 			= STATE_LDR;
				else if (IR_data[`OC] == `OC_LEA) next_state 			= STATE_LEA;
				else if (IR_data[`OC] == `OC_NOT) next_state 			= STATE_NOT;
				else if (IR_data[`OC] == `OC_ST) next_state 			= STATE_ST;
				else if (IR_data[`OC] == `OC_STI) next_state 			= STATE_STI1;
				else if (IR_data[`OC] == `OC_STR) next_state 			= STATE_STR;
				else if (IR_data[`OC] == `OC_HLT) next_state 			= STATE_HALT;
			end 	
			STATE_ADD1:		begin
				if (IR_data[`IMM_BIT_NUM] != `IS_IMM) next_state 		= STATE_ADD2;
				else if (IR_data[`IMM_BIT_NUM] == `IS_IMM) next_state = STATE_ADD3;
			end 
			STATE_ADD2: 	next_state 									= STATE_FETCH;
	 		STATE_ADD3: 	next_state = STATE_FETCH;
	 		STATE_AND1:		begin
				if (IR_data[`IMM_BIT_NUM] != `IS_IMM) next_state 		= STATE_AND2;
				else if (IR_data[`IMM_BIT_NUM] == `IS_IMM) next_state = STATE_AND3;
			end 
	 		STATE_AND2: 	next_state = STATE_FETCH;
	 		STATE_AND3: 	next_state = STATE_FETCH;
	 		STATE_BR1: 	begin
				 if ((IR_data[`BR_N] & N) | (IR_data[`BR_Z] & Zed) | (IR_data[`BR_P] & P)) next_state = STATE_BR2;
				 else next_state = STATE_FETCH;
			end 
	 		STATE_BR2: 		next_state = STATE_FETCH;
	 		STATE_JMP: 		next_state = STATE_FETCH;
	 		STATE_JS:		begin
				if (IR_data[`JSR_BIT_NUM] != `IS_JSR) next_state 		= STATE_JSRR;
				else if (IR_data[`JSR_BIT_NUM] == `IS_JSR) next_state 	= STATE_JSR;
			end 
	 		STATE_JSR: 		next_state 									= STATE_FETCH;
	 		STATE_JSRR: 	next_state 									= STATE_FETCH;
	 		STATE_LD: 		next_state 									= STATE_FETCH;
	 		STATE_LDI1: 	next_state 									= STATE_LDI2;
	 		STATE_LDI2:		next_state  								= STATE_FETCH;
	 		STATE_LDR:		next_state  								= STATE_FETCH;
	 		STATE_LEA:		next_state  								= STATE_FETCH;
	 		STATE_NOT:		next_state  								= STATE_FETCH;
	 		//STATE_RET: 		next_state  								= STATE_FETCH; not necessary
	 		STATE_ST: 		next_state  								= STATE_FETCH;
	 		STATE_STI1:		next_state  								= STATE_STI2;
	 		STATE_STI2:		next_state  								= STATE_FETCH;
	 		STATE_STR: 		next_state 									= STATE_FETCH;
			STATE_HALT:		next_state  								= STATE_HALT;
		endcase
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			state <= STATE_FETCH;
		end
		else begin
			// Add your next state here
			state <= next_state;
		end
	end

endmodule
