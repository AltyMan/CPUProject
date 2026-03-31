module RAM #(parameter INIT_FILE = "core/memory.hex") (
    input wire clock, read, write,
    input wire [8:0] address,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);

  reg [31:0] memory [0:511];
  reg [31:0] read_data_reg;
  
  initial begin
    if (INIT_FILE != "") begin
        $readmemh(INIT_FILE, memory);
    end
  end

  always @(posedge clock) begin
    if (write) begin
      memory[address] <= write_data;
    end
  end

  always @(negedge clock) begin
    if (read) begin
        read_data_reg <= memory[address];
    end
  end

  assign read_data = (read == 1'b1) ? read_data_reg : 32'b0;
  
endmodule