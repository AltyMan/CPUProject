module RAM (clock, read, write, address, write_data, read_data);
  input clock;
  input read;
  input write;
  input [8:0] address;
  input [31:0] write_data;
  output wire [31:0] read_data;

  reg [31:0] memory [0:511];
  
  initial begin
    $readmemh("core/memory.hex", memory);
  end

  always @(posedge clock)
  begin
    if (write == 1)
      memory[address] <= write_data;
  end

  assign read_data = (read == 1) ? memory[address] : 32'b0;
  
endmodule
