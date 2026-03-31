`timescale 1ns / 10ps

module Motherboard(
    input wire CLOCK_50,
    input wire [2:0] KEY,
    input wire [8:0] SW,
    output wire [5:5] LEDR,
    output wire [7:0] HEX0,
    output wire [7:0] HEX1
);

reg [19:0] reset_counter = 0;
reg clean_reset = 0;
always @(posedge CLOCK_50) begin
    if (~KEY[0]) begin 
        reset_counter <= 20'd1000000;
        clean_reset <= 1'b1;
    end else if (reset_counter > 0) begin
        reset_counter <= reset_counter - 1'b1;
        clean_reset <= 1'b1;
    end else begin
        clean_reset <= 1'b0;
    end
end

reg [19:0] stop_counter = 0;
reg clean_stop = 0;
always @(posedge CLOCK_50) begin
    if (~KEY[1]) begin
        stop_counter <= 20'd1000000;
        clean_stop <= 1'b1;
    end else if (stop_counter > 0) begin
        stop_counter <= stop_counter - 1'b1;
        clean_stop <= 1'b1;
    end else begin
        clean_stop <= 1'b0;
    end
end

reg irq_sync_1 = 0;
reg irq_sync_2 = 0;
always @(posedge CLOCK_50) begin
    irq_sync_1 <= ~KEY[2];
    irq_sync_2 <= irq_sync_1;
end
wire irq_pulse = irq_sync_1 & ~irq_sync_2;

wire [31:0] InPortData;
assign InPortData = {23'b0, SW[8:0]}; 
wire [31:0] OutPortData;
wire cpu_run;

DataPath dp(
    .clock(CLOCK_50),
    .clear(clean_reset),
    .stop(clean_stop),
    .IRQ(irq_pulse),
    .InPortData(InPortData),
    .OutPortData(OutPortData),
    .run(cpu_run)
);

assign LEDR[5] = cpu_run;

SevenSegDisplay hex0(
    .clk(CLOCK_50),
    .data(OutPortData[3:0]),
    .seg(HEX0)
);
SevenSegDisplay hex1(
    .clk(CLOCK_50),
    .data(OutPortData[7:4]),
    .seg(HEX1)
);

endmodule