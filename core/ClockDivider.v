`timescale 1ns / 10ps

module ClockDivider#(parameter DIVISOR = 25000000)(
    input wire clk_in,
    input wire reset,
    output reg clk_out
);
reg [31:0] counter;
always @(posedge clk_in or posedge reset) begin
    if (reset) begin
        counter <= 32'd0;
        clk_out <= 1'b0;
    end else begin
        if (counter >= (DIVISOR - 1)) begin
            counter <= 32'd0;
            clk_out <= ~clk_out;
        end else begin
            counter <= counter + 1'b1;
        end
    end
end
endmodule