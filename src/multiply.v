`default_nettype none

module approx_mul #(parameter BITS=16) (
    input signed [2:-(BITS-3)] x,
    input signed [2:-(BITS-3)] y,
    output wire signed [5:-(BITS-2)] xy
);

    wire signed [5:-BITS-2] hihi = $signed(x[2:-BITS/2-1]) * $signed(y[2:-BITS/2-1]);

    wire signed [2:-6] hi_x_corrected = x[2] ? (x[2:-6] + 9'd1) : x[2:-6];
    wire signed [2:-6] hi_y_corrected = y[2] ? (y[2:-6] + 9'd1) : y[2:-6];

    /* verilator lint_off UNUSEDSIGNAL */
    wire signed [1-BITS/2:-BITS-3] hilo_t = hi_x_corrected * $signed({1'b0, y[-BITS/2-2:-(BITS-3)]});
    wire signed [1-BITS/2:-BITS-3] lohi_t = hi_y_corrected * $signed({1'b0, x[-BITS/2-2:-(BITS-3)]});
    /* verilator lint_on UNUSEDSIGNAL */

    wire signed [1-BITS/2:-BITS-2] hilo = hilo_t[1-BITS/2:-BITS-2];
    wire signed [1-BITS/2:-BITS-2] lohi = lohi_t[1-BITS/2:-BITS-2];

    /* verilator lint_off UNUSEDSIGNAL */
    wire signed [6:-BITS-2] result = hihi + {{(4+BITS/2){hilo[1-BITS/2]}}, hilo[1-BITS/2:-BITS-2]} + {{(4+BITS/2){lohi[1-BITS/2]}}, lohi[1-BITS/2:-BITS-2]};
    /* verilator lint_on UNUSEDSIGNAL */

    assign xy = result[5:-(BITS-2)];

`ifdef FORMAL
    reg past_valid = 0;
    wire signed [5:-(2*BITS-6)] xy_exact = x * y;
    wire signed [5:-(2*BITS-6)] xy_padded = {xy, {(BITS-4){1'b0}}};
    wire signed [5:-(2*BITS-6)] diff = xy_exact - xy_padded;
    int error = BITS <= 16 ? 1 : 1 << (BITS - 16);

    always @(posedge clk) begin
        past_valid <= 1;

        if (past_valid) begin
            assert($signed(diff[5:-(BITS-2)]) <= error);
            assert($signed(diff[5:-(BITS-2)]) >= -error);
        end
    end
`endif
endmodule
