// Include all the files in the folder 
// Helper functions for the rotate operations
  //  alu/ror.v 
  //  alu/rol.v
// Keeps rotate logic out of the main ALU modules and avoids duplicated code

`include "add.v"
`include "and.v"
`include "div.v"
`include "mul.v"
`include "neg.v"
`include "not.v"
`include "or.v"
`include "rol.v"
`include "ror.v"
`include "shl.v"
`include "shr.v"
`include "shra.v"
`include "sub.v"


module helper;
  function automatic [31:0] rol32(input [31:0] x, input [4:0] sh);
    begin
      rol32 = (sh == 0) ? x : ((x << sh) | (x >> (32 - sh)));
    end
  endfunction

  function automatic [31:0] ror32(input [31:0] x, input [4:0] sh);
    begin
      ror32 = (sh == 0) ? x : ((x >> sh) | (x << (32 - sh)));
    end
  endfunction
endmodule
