module ram (clock, read, write, address, write_data, read_data);
  input clock;
  input read;
  input write;
  input [8:0] address;
  input [31:0] write_data;
  output reg [31:0] read_data;

  reg [31:0] memory [511:0];

  always @(posedge clock)
  begin
    if (read == 1)
      read_data <= memory[address];
    
    if (write == 1)
      memory[address] <= write_data;
  end

  initial begin
    $readmemh("memory.hex", memory);
  end
  
endmodule

  
