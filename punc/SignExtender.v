//==============================================================================
// Single Input to get sign extended, input signal parameter (INPUT_WIDTH)
//==============================================================================

module SignExtender #(parameter INPUT_WIDTH = 5)(
    input [INPUT_WIDTH -1:0] signal,
    output [15:0] sext_sig
);
    localparam PAD_WIDTH = 16 - INPUT_WIDTH;

    wire [PAD_WIDTH - 1:0] pad;

    genvar i;
    generate 
        for (i = 0; i < PAD_WIDTH; i = i + 1) begin
            assign pad[i] = signal[INPUT_WIDTH - 1];
        end
    endgenerate

    assign sext_sig = {pad, signal};
endmodule


