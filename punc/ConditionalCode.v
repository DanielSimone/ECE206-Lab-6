//==============================================================================
// Conditional Code Module with Multiplexor, Conditional Code Registers, 
// and 16-bit Comparator
// 2 inputs for the multiplexor, 1 MUX select signal, and set signal
//==============================================================================

`include "Defines.v"


module ConditionalCode#(parameter DATA_WIDTH = 16)(
    // Input Clock
    input clk,
    input rst,

    // Comparator MUX selector signal
    input comp_sel,

    // MUX inputs
    input [DATA_WIDTH - 1: 0] m0, 
    input [DATA_WIDTH - 1: 0] m1,

    //Conditional Code Load Signal
    input load,

    output reg zero,
    output reg pos,
    output reg neg
);

    // 16-bit Comparator MUX 
    reg [DATA_WIDTH - 1: 0] comp_mux;
    always @(*) begin
        // Initial Value
        comp_mux = 0;

        case (comp_sel)
            `MEM_OUT_ONE: begin
                comp_mux = m0;
            end
            `ALU_OUT_ONE: begin
                comp_mux = m1;
            end
        endcase 
    end
    
    // Zero Register 
    initial zero = 1'b0;
    always @(posedge clk) begin
        if (rst) zero <= 1'b0;
        else if (load) begin
            if (comp_mux == 0) zero <= 1'b1;
            else if (comp_mux != 0) zero <= 1'b0;
        end    
    end 

    // Positive Register 
    initial pos = 1'b0;
    always @(posedge clk) begin
        if (rst) pos <= 1'b0;
        else if (load) begin
            if (comp_mux == 0) pos <= 1'b0;
            else if (comp_mux != 0) pos <= ~(comp_mux[DATA_WIDTH-1]);
        end    
    end 

    // Negative Register 
    initial neg = 1'b0;
    always @(posedge clk) begin
        if (rst) neg <= 1'b0;
        else if (load) begin
            neg <= (comp_mux[DATA_WIDTH-1]);
        end    
    end 
endmodule