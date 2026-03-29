`timescale 1ns / 10ps
`include "core/DataPath.v"
`include "core/ClockDivider.v"
`include "core/SevenSegDisplay.v"

module Motherboard#(parameter DIVISOR = 25000000)(
	input wire clock_50mhz, clear, stop,
	input wire [1:0] key, // key[0] = reset, key[1] = stop
    input wire [7:0] switch,
    output wire [5:5] LEDR,
    output wire [7:0] HEX0,
    output wire [7:0] HEX1
);
wire cpu_clock;
ClockDivider #(.DIVISOR(DIVISOR)) clk_div(
    .clk_in(clock_50mhz),
    .reset(~key[0]),
    .clk_out(cpu_clock)
);
wire [31:0] InPortData;
wire [31:0] OutPortData;
assign InPortData = {24'b0, switch[7:0]};
wire cpu_run;
DataPath dp(
    .clock(cpu_clock),
    .clear(~key[0]),
    .stop(~key[1]),
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