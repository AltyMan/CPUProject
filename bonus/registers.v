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
reg [DATA_WIDTH-1:0]pc_q;
initial pc_q = INIT;
always @(posedge clock)
	begin
        if (clear) begin
            pc_q <= INIT;
        end
		else if (jump_signal) begin
            pc_q <= branch_address;
        end
		else if (enable) begin
        	if (branch_address == pc_q) begin
            	pc_q <= pc_q + 1;
			end else begin
				pc_q <= branch_address;
			end
        end
    end
assign PCOut = pc_q[DATA_WIDTH-1:0];
endmodule

module ir #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 32'h0)(
	input clear, clock, enable, 
	input [DATA_WIDTH_IN-1:0]BusMuxOut,
	output wire [DATA_WIDTH_OUT-1:0]IROut
);
reg [DATA_WIDTH_IN-1:0]ir_q;
initial ir_q = INIT;
always @ (posedge clock)
	begin
		if (clear) begin
			ir_q <= INIT;
		end
		else if (enable) begin
			ir_q <= BusMuxOut;
		end
	end
assign IROut = ir_q[DATA_WIDTH_OUT-1:0];
endmodule

module mar #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 9, INIT = 32'h0)(
	input clear, clock, enable, 
	input [DATA_WIDTH_IN-1:0]BusMuxOut,
	output wire [DATA_WIDTH_OUT-1:0]MAROut
);
reg [DATA_WIDTH_IN-1:0]mar_q;
initial mar_q = INIT;
always @ (posedge clock)
	begin
		if (clear) begin
			mar_q <= {DATA_WIDTH_IN{1'b0}};
		end
		else if (enable) begin
			mar_q <= BusMuxOut;
		end
	end
assign MAROut = mar_q[DATA_WIDTH_OUT-1:0];
endmodule

module mdr #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 32'h0)(
	input clear, clock, enable, read,
	input [DATA_WIDTH_IN-1:0]BusMuxOut,
    input [DATA_WIDTH_IN-1:0]Mdatain,
	output wire [DATA_WIDTH_OUT-1:0]BusMuxIn,
	output wire [DATA_WIDTH_OUT-1:0]Mdataout
);
reg [DATA_WIDTH_IN-1:0]mdr_q;
initial mdr_q = INIT;
always @ (posedge clock)
	begin 
		if (clear) begin
			mdr_q <= {DATA_WIDTH_IN{1'b0}};
		end
		else if (enable) begin
			mdr_q <= read ? Mdatain : BusMuxOut;
		end
	end
assign BusMuxIn = mdr_q[DATA_WIDTH_OUT-1:0];
assign Mdataout = mdr_q[DATA_WIDTH_OUT-1:0];
endmodule

module inport #(parameter DATA_WIDTH = 32)(
	input clear, strobe,
	input wire [DATA_WIDTH-1:0]InData,
	output wire [DATA_WIDTH-1:0]BusMuxIn
);
reg [DATA_WIDTH-1:0]inport_q;
initial inport_q = 0;
always @ (posedge clear or posedge strobe)
	begin 
		if (clear) begin
			inport_q <= {DATA_WIDTH{1'b0}};
		end
		else begin
			inport_q <= InData;
		end
	end
assign BusMuxIn = inport_q[DATA_WIDTH-1:0];
endmodule

module outport #(parameter DATA_WIDTH = 32)(
	input clear, clock, enable,
	input wire [DATA_WIDTH-1:0]BusMuxOut,
	output wire [DATA_WIDTH-1:0]OutData
);
reg [DATA_WIDTH-1:0]outport_q;
initial outport_q = 0;
always @ (posedge clock)
	begin 
		if (clear) begin
			outport_q <= {DATA_WIDTH{1'b0}};
		end
		else if (enable) begin
			outport_q <= BusMuxOut;
		end
	end
assign OutData = outport_q[DATA_WIDTH-1:0];
endmodule

module epc #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 32'h0)(
    input clear, clock, enable, 
    input [DATA_WIDTH_IN-1:0] BusMuxOut,
    output wire [DATA_WIDTH_OUT-1:0] EPCOut
);
reg [DATA_WIDTH_IN-1:0] epc_q;
initial epc_q = INIT;

always @ (posedge clock)
    begin
        if (clear) begin
            epc_q <= INIT;
        end
        else if (enable) begin
            epc_q <= BusMuxOut;
        end
    end
assign EPCOut = epc_q[DATA_WIDTH_OUT-1:0];
endmodule

module IE #(parameter INIT = 1'b0)(
    input clear, clock,
    input set_IE,
    input clear_IE,
    output wire IE_out
);
reg ie_q;
initial ie_q = INIT;

always @ (posedge clock)
    begin
        if (clear) begin
            ie_q <= 1'b0;
        end 
        else if (clear_IE) begin 
            ie_q <= 1'b0;
        end
        else if (set_IE) begin
            ie_q <= 1'b1;
        end
    end
assign IE_out = ie_q;
endmodule