//==============================================================================
// Datapath for PUnC LC3 Processor
//==============================================================================

`include "Memory.v"
`include "RegisterFile.v"
`include "ALU_module.v"
`include "SignExtender.v"
`include "ConditionalCode.v"
`include "Defines.v"

module PUnCDatapath#(parameter DATA_WIDTH = 16)(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// DEBUG Signals
	input  wire [DATA_WIDTH - 1:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,

	output wire [DATA_WIDTH - 1:0] mem_debug_data,
	output wire [DATA_WIDTH - 1:0] rf_debug_data,
	output wire [DATA_WIDTH - 1:0] pc_debug_data,

	// Inputs from controller
	// MUX and ALU Control signals
	input [1:0] rf_w_data_sel,
	input Mem_w_addr_sel,
	input [1:0] Mem_r_addr_sel, 
	input PC_sel,
	input ALU_A_sel,
	input [2:0] ALU_B_sel,
	input [1:0] ALU_op,
	input comp_sel,
	
	// RegFile Control Signals
	// Specify DR, Rf1:(BaseR, R7, SR1) and Rf2:(SR, SR2) with the corresponding port on Regfile for clarity
	input [2:0] dr_w_data,
	input rf_w_en,
	input [2:0] Rf1_addr_0,
	input [2:0] Rf2_addr_1,
	

	// Memory Control Signals
	input mem_ld,

	// Memory Value Control
	input mem_val_ld,
	
	// PC Control Signals 
	input PC_ld,
	input PC_cnt,

	// Instruction Register (IR) Control Signals
	input IR_ld,
	// input [DATA_WIDTH - 1:0] instruction, not necessary since take instruction right from memory in fetch phase 

	// Instruction Specific Constants
	input [4:0] imm5,
	input [5:0] offset6,
	input [8:0] PCoffset9,
	input [10:0] PCoffset11,

	// Set the Condition Code
	input setcc,
	
	// Datapath Outputs 
	// output wire [DATA_WIDTH - 1:0] PC_data, retrieving instructions are self contained 
	output wire [DATA_WIDTH - 1:0] IR_data,
	//output wire bit_equal,
	output Zed,
	output N,
	output P
);

	// Local Registers
	//----------------------------------------------------------------------
	// PC Counter 
	//----------------------------------------------------------------------

	reg  [DATA_WIDTH - 1:0] pc;
	always @(posedge clk) begin
		if (rst) pc <= 0;
		else if (PC_ld) begin
			pc <= PC_MUX;
		end
		else if (PC_cnt) begin
			pc <= pc + 1;
		end
	end
	//assign PC_data = pc;

	//----------------------------------------------------------------------
	// Instruction Register
	//----------------------------------------------------------------------

	reg  [DATA_WIDTH - 1:0] ir;
	always @(posedge clk) begin
		if (rst) ir <= 0;
		else if (IR_ld) begin
			ir <= mem_rdata_0;
		end
	end
	assign IR_data = ir;

	// Declare other local wires and registers here

	// Assign PC debug net
	assign pc_debug_data = pc;

	// Connection Wires 
	wire [DATA_WIDTH - 1:0] rf_rdata_0; // BaseR, SR1, R7
	wire [DATA_WIDTH - 1:0] rf_rdata_1; // SR2, SR
	wire [DATA_WIDTH - 1:0] mem_rdata_0; // Mem_out 
	wire [DATA_WIDTH - 1:0] alu_out; // ALU output

	//----------------------------------------------------------------------
	// Memory Module
	//----------------------------------------------------------------------

	// 1024-entry 16-bit memory (connect other ports)
	Memory mem(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (Mem_r_addr_MUX), // Connection Mem_r_addr_MUX
		.r_addr_1 (mem_debug_addr),
		.w_addr   (Mem_w_addr_MUX), // Connection Mem_w_addr_MUX
		.w_data   (rf_rdata_1),
		.w_en     (mem_ld),
		.r_data_0 (mem_rdata_0),
		.r_data_1 (mem_debug_data)
	);

	//----------------------------------------------------------------------
	// Register File Module
	//----------------------------------------------------------------------

	// 8-entry 16-bit register file (connect other ports)
	RegisterFile rfile(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (Rf1_addr_0),
		.r_addr_1 (Rf2_addr_1),
		.r_addr_2 (rf_debug_addr),
		.w_addr   (dr_w_data), 
		.w_data   (rf_w_data_MUX), // rf_w_data_MUX
		.w_en     (rf_w_en),
		.r_data_0 (rf_rdata_0),
		.r_data_1 (rf_rdata_1),
		.r_data_2 (rf_debug_data)
	);
	
	//----------------------------------------------------------------------
	// ALU Implementation
	//----------------------------------------------------------------------

	ALUModule PuncALU(
		// Operation Select
		.op_sel		(ALU_op),
		// MUX selects
		.inputA_sel (ALU_A_sel),
		.inputB_sel (ALU_B_sel),
		// ALU A Mux input
		.a0			(rf_rdata_0),
		.a1			(pc),
		// ALU B Mux input 
		.b0			(sextimm5), // sext(imm5)
		.b1			(sextoffset6),	// sext(offset6)
		.b2			(sextPCoffset9),	// sext(PCoffset9)
		.b3			(sextPCoffset11),	// sext(PCoffset11)
		.b4			(rf_rdata_1),
		// ALU output
		.ALU_result (alu_out)
	);

	//----------------------------------------------------------------------
	// Memory Value Synchronous Register 
	//----------------------------------------------------------------------
	reg [DATA_WIDTH - 1:0] mem_value;
	always @(posedge clk) begin
		if (rst) mem_value <= 0;
		else if (mem_val_ld) begin
			mem_value <= mem_rdata_0;
		end
	end

	//----------------------------------------------------------------------
	// SignExtender Implementations
	//----------------------------------------------------------------------

	wire [DATA_WIDTH - 1:0] sextimm5;
	wire [DATA_WIDTH - 1:0] sextoffset6;
	wire [DATA_WIDTH - 1:0] sextPCoffset9;
	wire [DATA_WIDTH - 1:0] sextPCoffset11;
	SignExtender #(.INPUT_WIDTH(5)) imm5_ext (
		.signal(imm5),
		.sext_sig(sextimm5)
	);

	SignExtender #(.INPUT_WIDTH(6)) offset6_ext (
		.signal(offset6),
		.sext_sig(sextoffset6)
	);

	SignExtender #(.INPUT_WIDTH(9)) PCoffset9_ext (
		.signal(PCoffset9),
		.sext_sig(sextPCoffset9)
	);

	SignExtender #(.INPUT_WIDTH(11)) PCoffset11_ext (
		.signal(PCoffset11),
		.sext_sig(sextPCoffset11)
	);

	//----------------------------------------------------------------------
	// Conditional Code Module
	//----------------------------------------------------------------------

	ConditionalCode Conditions(
		.clk(clk),
		.rst(rst),
		.comp_sel(comp_sel),
		.m0(mem_rdata_0),
		.m1(alu_out),
		.load(setcc),
		.zero(Zed),
		.pos(P),
		.neg(N)
	);

	
	// Implement Mem_r_addr Multiplexor
	reg [DATA_WIDTH - 1:0] Mem_r_addr_MUX = 15'd0; // Eliminate assignment if error 

	always @(*) begin
		// Unassigned value
		Mem_r_addr_MUX = 0; 

		case (Mem_r_addr_sel)
			// Different signals
			`MEM_VALUE_TWO: begin 
				Mem_r_addr_MUX = mem_value;
			end 
			`INSTR_READ: begin
				Mem_r_addr_MUX = pc;
			end
			`ALU_OUT_TWO: begin
				Mem_r_addr_MUX = alu_out;
			end
		endcase 
	end 

	// Implement Mem_w_addr Multiplexor 
	reg [DATA_WIDTH - 1:0] Mem_w_addr_MUX = 15'd0; // Eliminate assignment if error 

	always @(*) begin 
		//Inital value
		Mem_w_addr_MUX = 0; 

		case (Mem_w_addr_sel)
			`MEM_VALUE: begin 
				Mem_w_addr_MUX = mem_value;
			end 
			`ALU_OUT_ONE: begin
				Mem_w_addr_MUX = alu_out;
			end
		endcase 
	end 

	// Implement rf_w_data Multiplexor 
	reg [DATA_WIDTH - 1:0] rf_w_data_MUX = 15'd0; // Eliminate assignment if error 
	initial rf_w_data_MUX = 0;

	always @(*) begin
		//Initial Value 
		rf_w_data_MUX = 0;

		case (rf_w_data_sel)
			`PC_RF: begin
				rf_w_data_MUX = pc;
			end
			`ALU_OUT_TWO: begin
				rf_w_data_MUX = alu_out;
			end
			`MEM_OUT_TWO: begin
				rf_w_data_MUX = mem_rdata_0;
			end
		endcase 
	end

	// Implement PC Multiplexor
	reg [DATA_WIDTH - 1:0] PC_MUX = 15'd0; // Eliminate assignment if error 

	always @(*) begin
		// Initial Value 
		PC_MUX = 0;

		case (PC_sel)
			`BASER_SR1: begin
				PC_MUX = rf_rdata_0;
			end
			`ALU_OUT_ONE: begin
				PC_MUX = alu_out;
			end
		endcase 
	end

endmodule
