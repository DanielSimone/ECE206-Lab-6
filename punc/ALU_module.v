//==============================================================================
// ALU Module with 2 Operation Select Ports,
// 1 ALU_A MUX select ports, 3 ALU_B MUX select ports
// 7 External Value input lines
//==============================================================================

`include "Defines.v"

module ALUModule#(parameter DATA_WIDTH = 16)(
    // Operation Select
    input [1:0] op_sel,

    // ALU_(A or B)_MUX sel 
    input inputA_sel,
    input [2:0] inputB_sel,

    // Input A external val
    input [DATA_WIDTH - 1:0] a0,
    input [DATA_WIDTH - 1:0] a1,

    // Input B external val
    input [DATA_WIDTH - 1:0] b0,
    input [DATA_WIDTH - 1:0] b1,
    input [DATA_WIDTH - 1:0] b2,
    input [DATA_WIDTH - 1:0] b3,
    input [DATA_WIDTH - 1:0] b4,

    output reg [DATA_WIDTH - 1:0] ALU_result
);
    

    // Input A MUX 
    reg [DATA_WIDTH - 1:0] inputA;
    reg [DATA_WIDTH - 1:0] inputB; 

    always @(*) begin
        // Initial Values
        inputA = 0;
        inputB = 0;

        case (inputA_sel)
            `BASER_SR1: begin
                inputA = a0;
            end
            `PC_ALU: begin
                inputA = a1;
            end
        endcase 

        case (inputB_sel)
            `IMM5: begin
                inputB = b0;
            end
            `OFFSET6: begin
                inputB = b1;
            end
            `PCOFFSET9: begin
                inputB = b2;
            end
            `PCOFFSET11: begin
                inputB = b3;
            end
            `SR_SR2: begin
                inputB = b4;
            end
        endcase
    end

    // Operation Selection 
    always @(*) begin
        // Implicit value
        ALU_result = 0;
            
        case (op_sel)
            `ADD: begin
                ALU_result = inputA + inputB;
            end
            `AND: begin
                ALU_result = inputA & inputB;
            end
            `NOT: begin
                ALU_result = ~(inputB);
            end
        endcase 
    end

endmodule