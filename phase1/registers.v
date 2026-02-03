module register #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 32'h0)(
	input clear, clock, enable, 
	input [DATA_WIDTH_IN-1:0]BusMuxOut,
	output wire [DATA_WIDTH_OUT-1:0]BusMuxIn
);
reg [DATA_WIDTH_IN-1:0]q;
initial q = INIT;
always @ (posedge clock)
		begin 
			if (clear) begin
				q <= {DATA_WIDTH_IN{1'b0}};
			end
			else if (enable) begin
				q <= BusMuxOut;
			end
		end
	assign BusMuxIn = q[DATA_WIDTH_OUT-1:0];
endmodule

module ir #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 32'h0)(
	input clear, clock, enable, 
	input [DATA_WIDTH_IN-1:0]BusMuxOut,
	output wire [DATA_WIDTH_OUT-1:0]IROut
);
reg [DATA_WIDTH_IN-1:0]ir;
initial ir = INIT;
always @ (posedge clock)
		begin
			if (clear) begin
				ir <= {DATA_WIDTH_IN{1'b0}};
			end
			else if (enable) begin
				ir <= BusMuxOut;
			end
		end
	assign IROut = ir[DATA_WIDTH_OUT-1:0];
endmodule

module mar #(parameter DATA_WIDTH = 32, INIT = 32'h0)(
	input clear, clock, enable, 
	input [DATA_WIDTH-1:0]BusMuxOut,
	output wire [DATA_WIDTH-1:0]MAROut
);
reg [DATA_WIDTH-1:0]q;
initial q = INIT;
always @ (posedge clock)
		begin
			if (clear) begin
				q <= {DATA_WIDTH{1'b0}};
			end
			else if (enable) begin
				q <= BusMuxOut;
			end
		end
		assign MAROut = q[DATA_WIDTH-1:0];
endmodule

module mdr #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 32'h0)(
	input clear, clock, enable, read,
	input [DATA_WIDTH_IN-1:0]BusMuxOut,
    input [DATA_WIDTH_IN-1:0]Mdatain,
	output wire [DATA_WIDTH_OUT-1:0]BusMuxIn,
	output wire [DATA_WIDTH_OUT-1:0]Mdataout
);
reg [DATA_WIDTH_IN-1:0]q;
initial q = INIT;
always @ (posedge clock)
		begin 
			if (clear) begin
				q <= {DATA_WIDTH_IN{1'b0}};
			end
			else if (enable) begin
				q <= read ? Mdatain : BusMuxOut;
			end
		end
	assign BusMuxIn = q[DATA_WIDTH_OUT-1:0];
endmodule