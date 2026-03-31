`timescale 1ns / 10ps

module Motherboard#(parameter DIVISOR = 3)(
	input wire CLOCK_50,
	input wire [2:0] KEY, // key[0] = reset, key[1] = stop, key[2] = irq
    input wire [7:0] SW,
    output wire [5:5] LEDR,
    output wire [7:0] HEX0,
    output wire [7:0] HEX1
);
wire cpu_clock;
ClockDivider #(.DIVISOR(DIVISOR)) clk_div(
    .clk_in(CLOCK_50),
    .reset(~KEY[0]),
    .clk_out(cpu_clock)
);
wire [31:0] InPortData;
wire [31:0] OutPortData;
assign InPortData = {24'b0, SW[7:0]};
wire cpu_run;
DataPath dp(
    .clock(cpu_clock),
    .clear(~KEY[0]),
    .stop(~KEY[1]),
    .IRQ(KEY[2]),
    .InPortData(InPortData),
    .OutPortData(OutPortData),
    .run(cpu_run)
);
assign LEDR[5] = cpu_run;
SevenSegDisplay hex0(
    .clk(cpu_clock),
    .data(OutPortData[3:0]),
    .seg(HEX0)
);
SevenSegDisplay hex1(
    .clk(cpu_clock),
    .data(OutPortData[7:4]),
    .seg(HEX1)
);
endmodule