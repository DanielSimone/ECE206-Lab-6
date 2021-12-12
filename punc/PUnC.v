//==============================================================================
// Module for PUnC LC3 Processor
//==============================================================================

`include "PUnCDatapath.v"
`include "PUnCControl.v"

module PUnC(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Debug Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data
);

	//----------------------------------------------------------------------
	// Interconnect Wires
	//----------------------------------------------------------------------

	// Declare your wires for connecting the datapath to the controller here
	wire Zed, P, N;
	wire [1:0] rf_w_data_sel, Mem_r_addr_sel, ALU_op;
	wire Mem_w_addr_sel, PC_sel, ALU_A_sel, comp_sel;
	wire [2:0] dr_w_data, Rf1_addr_0, Rf2_addr_1, ALU_B_sel;
	wire mem_ld, mem_val_ld, PC_ld, PC_cnt, IR_ld, rf_w_en, setcc; 
	wire [15:0] IR_data;
	wire [4:0] imm5;
	wire [5:0] offset6;
	wire [8:0] PCoffset9;
	wire [10:0] PCoffset11;

	//----------------------------------------------------------------------
	// Control Module
	//----------------------------------------------------------------------
	PUnCControl ctrl(
		.clk             (clk),
		.rst             (rst),

		// Add more ports here
		.IR_data(IR_data),
		.Zed(Zed),
		.P(P),
		.N(N),
		// Out,puts to datapath
		// MUX and ALU Control signals
		.rf_w_data_sel(rf_w_data_sel),
	 	.Mem_w_addr_sel(Mem_w_addr_sel),
	 	.Mem_r_addr_sel(Mem_r_addr_sel),
	 	.PC_sel(PC_sel),
	 	.ALU_A_sel(ALU_A_sel),
		.ALU_B_sel(ALU_B_sel),
	 	.ALU_op(ALU_op),
		.comp_sel(comp_sel),
		// RegFile Control Signals
		// Specify DR, Rf1:(BaseR, R7, SR1) and Rf2:(SR, SR2) with the corresponding port on Regfile for clarity
		.dr_w_data(dr_w_data),
		.rf_w_en(rf_w_en),
		.Rf1_addr_0(Rf1_addr_0),
		.Rf2_addr_1(Rf2_addr_1),
		// Memory Control Signals
	 	.mem_ld(mem_ld),
		// Memory Value Control
	 	.mem_val_ld(mem_val_ld),
		//PC Control Signals 
	 	.PC_ld(PC_ld),
		.PC_cnt(PC_cnt),
		//Instruction Register (IR) Control Signals
	 	.IR_ld(IR_ld),
		//Instruction Specific Constants
	 	.imm5(imm5),
	 	.offset6(offset6),
	 	.PCoffset9(PCoffset9),
	 	.PCoffset11(PCoffset11),
		// Set the Condition Code
 		.setcc(setcc)
	);

	//----------------------------------------------------------------------
	// Datapath Module
	//----------------------------------------------------------------------
	PUnCDatapath dpath(
		.clk             (clk),
		.rst             (rst),

		.mem_debug_addr   (mem_debug_addr),
		.rf_debug_addr    (rf_debug_addr),
		.mem_debug_data   (mem_debug_data),
		.rf_debug_data    (rf_debug_data),
		.pc_debug_data    (pc_debug_data),

		// Add more ports here
		// Inputs from controller
		// MUX and ALU Control signals
		.rf_w_data_sel(rf_w_data_sel),
		.Mem_w_addr_sel(Mem_w_addr_sel),
		.Mem_r_addr_sel(Mem_r_addr_sel),
		.PC_sel(PC_sel),
		.ALU_A_sel(ALU_A_sel),
		.ALU_B_sel(ALU_B_sel),
		.ALU_op(ALU_op),
		.comp_sel(comp_sel),
		// RegFile Control Signals
		// Specify DR, Rf1:(BaseR, R7, SR1) and Rf2:(SR, SR2) with the corresponding port on Regfile for clarity
		.dr_w_data(dr_w_data),
		.rf_w_en(rf_w_en),
		.Rf1_addr_0(Rf1_addr_0),
		.Rf2_addr_1(Rf2_addr_1),
		// Memory Control Signals
		.mem_ld(mem_ld),
		// Memory Value Control
		.mem_val_ld(mem_val_ld),
		// PC Control Signals 
		.PC_ld(PC_ld),
		.PC_cnt(PC_cnt),
		// Instruction Register (IR) Control Signals
		.IR_ld(IR_ld),
		// input [DATA_WIDTH - 1:0] instruction, not necessary since take instruction right from memory in fetch phase 
		// Instruction Specific Constants
		.imm5(imm5),
		.offset6(offset6),
		.PCoffset9(PCoffset9),
		.PCoffset11(PCoffset11),

		// Set the Condition Code
		.setcc(setcc),
	
		// Datapath Outputs 
		// output wire [DATA_WIDTH - 1:0] PC_data, retrieving instructions are self contained 
		.IR_data(IR_data),
		.Zed(Zed),
		.N(N),
		.P(P)
	);

endmodule
