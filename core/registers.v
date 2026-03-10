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

module reg0logic #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 32'h0)(
	input BAout,
	input [DATA_WIDTH_IN-1:0]qOut,
	output wire [DATA_WIDTH_OUT-1:0]BusMuxInR0
);
wire g1;
not (g1, BAout);
assign BusMuxInR0 = qOut & {DATA_WIDTH_IN{g1}};
endmodule

module pc #(parameter DATA_WIDTH = 32, INIT = 32'h0) (
	input clear, clock, enable, 
	input jump_signal,
	input [DATA_WIDTH-1:0] branch_address,
	output wire [DATA_WIDTH-1:0]PCOut
);
reg [DATA_WIDTH-1:0]q;
initial q = INIT;
always @(posedge clock)
	begin
        if (clear) begin
            q <= INIT;
        end
		else if (enable) begin
            if (jump_signal) begin
                q <= branch_address;
            end 
			else begin
                q <= q + 4;
			end
        end
    end
assign PCOut = q[DATA_WIDTH-1:0];
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
			ir <= INIT;
		end
		else if (enable) begin
			ir <= BusMuxOut;
		end
	end
assign IROut = ir[DATA_WIDTH_OUT-1:0];
endmodule

module mar #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 9, INIT = 32'h0)(
	input clear, clock, enable, 
	input [DATA_WIDTH_IN-1:0]BusMuxOut,
	output wire [DATA_WIDTH_OUT-1:0]MAROut
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
assign MAROut = q[DATA_WIDTH_OUT-1:0];
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
assign Mdataout = q[DATA_WIDTH_OUT-1:0];
endmodule

module inport #(parameter DATA_WIDTH = 32)(
	input clear, clock, enable,
	input wire [DATA_WIDTH-1:0]InData,
	output wire [DATA_WIDTH-1:0]BusMuxIn
);
reg [DATA_WIDTH-1:0]q;
initial q = 0;
always @ (posedge clock)
	begin 
		if (clear) begin
			q <= {DATA_WIDTH{1'b0}};
		end
		else if (enable) begin
			q <= InData;
		end
	end
assign BusMuxIn = q[DATA_WIDTH-1:0];
endmodule

module outport #(parameter DATA_WIDTH = 32)(
	input clear, clock, enable,
	input wire [DATA_WIDTH-1:0]BusMuxOut,
	output wire [DATA_WIDTH-1:0]OutData
);
reg [DATA_WIDTH-1:0]q;
initial q = 0;
always @ (posedge clock)
	begin 
		if (clear) begin
			q <= {DATA_WIDTH{1'b0}};
		end
		else if (enable) begin
			q <= BusMuxOut;
		end
	end
assign OutData = q[DATA_WIDTH-1:0];
endmodule