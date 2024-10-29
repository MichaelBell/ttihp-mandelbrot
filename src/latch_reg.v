`default_nettype none

// A wrapper to use a latch as a register
// Note no reset - reset using data
module latch_reg #(
    parameter WIDTH=8
) (
    input wire clk,

    input wire wen,                 // Write enable
    input wire [WIDTH-1:0] data_in, // Data to write during second half of clock when wen is high

    output wire [WIDTH-1:0] data_out
);

    // For now just use flip flops for simplicity.
    reg [WIDTH-1:0] state;
    always @(posedge clk) begin
        if (wen) state <= data_in;
    end

    assign data_out = state;

endmodule
