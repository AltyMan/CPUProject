module control (
    input wire clock, reset, stop,
    input wire [31:0] IR,
    input wire CON_FF,
    input wire IRQ,
    input wire IE_out,
    output wire EPCin, EPCout,
    output wire IVRin, IVRout,
    output wire set_IE, clear_IE,
    output wire GPR_Rin, GPR_Rout,
    output wire [15:0] RinHI, RoutHI,
    output wire IRin, MARin, RZout, RYin, RBin, PCjump, MDRread, CONin,
    output wire [15:0] ALUControl,
    output wire Gra, Grb, Grc, BAout, Cout,
    output wire RAMread, RAMwrite,
    output wire InPortStrobe, OutPortEnable,
    output reg run
);

    wire op_halt = (IR[31:27] == 5'b11011);

    always @(posedge clock or posedge reset) begin
        if (reset) run <= 1'b1;
        else if (stop || op_halt) run <= 1'b0;
    end

    reg [2:0] state;
    wire T0 = (state == 3'd0);
    wire T1 = (state == 3'd1);
    wire T2 = (state == 3'd2);
    wire T3 = (state == 3'd3);
    wire T4 = (state == 3'd4);
    wire T5 = (state == 3'd5);

    wire T_INT1 = (state == 3'd6);
    wire T_INT2 = (state == 3'd7);

    wire [4:0] opcode = IR[31:27];
    wire op_add = (opcode == 5'b00000);
    wire op_sub = (opcode == 5'b00001);
    wire op_and = (opcode == 5'b00010);
    wire op_or = (opcode == 5'b00011);
    wire op_shr = (opcode == 5'b00100);
    wire op_shra = (opcode == 5'b00101);
    wire op_shl = (opcode == 5'b00110);
    wire op_ror = (opcode == 5'b00111);
    wire op_rol = (opcode == 5'b01000);
    wire op_neg = (opcode == 5'b01110);
    wire op_not = (opcode == 5'b01111);
    wire op_addi = (opcode == 5'b01001);
    wire op_andi = (opcode == 5'b01010);
    wire op_ori = (opcode == 5'b01011);
    wire op_mul = (opcode == 5'b01101);
    wire op_div = (opcode == 5'b01100);
    wire op_ld = (opcode == 5'b10000);
    wire op_ldi = (opcode == 5'b10001);
    wire op_st = (opcode == 5'b10010);
    wire op_br = (opcode == 5'b10101);
    wire op_jr = (opcode == 5'b10100);
    wire op_jal = (opcode == 5'b10011);
    wire op_mfhi = (opcode == 5'b11000);
    wire op_mflo = (opcode == 5'b11001);
    wire op_in = (opcode == 5'b10110);
    wire op_out = (opcode == 5'b10111);
    wire op_nop = (opcode == 5'b11010);
    wire op_rfi = (opcode == 5'b11100); // 0x1C
    wire op_ei = (opcode == 5'b11101); // 0x1D
    wire op_di = (opcode == 5'b11110); // 0x1E
    wire op_mtivr = (opcode == 5'b11111); // 0x1F

    wire is_alu_r = (op_add | op_sub | op_and | op_or | op_shr | op_shra | op_shl | op_ror | op_rol);
    wire is_alu_2op = (op_not | op_neg); 
    wire is_alu_i = (op_addi | op_andi | op_ori | op_ldi);
    wire is_md = (op_mul | op_div);

    wire instruction_done = 
        (T3 & (is_alu_r | is_alu_2op | is_alu_i)) | 
        (T5 & (op_ld | op_st)) |
        (T4 & op_br) |
        (T1 & (op_jr | op_mfhi | op_mflo | op_in | op_out | op_nop | op_rfi | op_ei | op_di | op_mtivr)) |
        (T2 & op_jal) | 
        (T4 & is_md);

    always @(posedge clock or posedge reset) begin
        if (reset) state <= 3'd0;
        else if (run) begin
            if (instruction_done) begin
                if (IRQ && IE_out) state <= 3'd6;
                else state <= 3'd0;
            end
            else if (T_INT2) state <= 3'd0;
            else state <= state + 1'b1;
        end
    end
    
    // Base Address Logic
    wire op_uses_base = (op_ld | op_st | op_ldi);
    wire is_r0_base = (IR[22:19] == 4'b0000);
    wire ba_active = (T1 & op_uses_base & is_r0_base);
    
    assign BAout = ba_active;

    // GPR Select Signals
    assign Gra = ((T3 & is_alu_r) | (T3 & is_alu_2op) | (T3 & is_alu_i) | (T5 & op_ld) | (T4 & op_st) | 
                 (T1 & op_br) | (T1 & op_jr) | (T2 & op_jal)| 
                 (T1 & op_mfhi) | (T1 & op_mflo) | (T1 & op_in) | (T1 & op_out) |
                 (T1 & is_md) | (T1 & is_alu_2op) | (T1 & op_mtivr)) & ~ba_active;

    assign Grb = ((T1 & is_alu_r) | (T1 & is_alu_i) | (T1 & op_ld) | (T1 & op_st) |
                 (T2 & is_md) | (T2 & is_alu_2op)) & ~ba_active;

    assign Grc = (T2 & is_alu_r);

    assign GPR_Rin = (T3 & is_alu_r) | (T3 & is_alu_2op) | (T3 & is_alu_i) | (T5 & op_ld) | (T1 & op_jal) | 
                     (T1 & op_mfhi) | (T1 & op_mflo) | (T1 & op_in);

    assign GPR_Rout = (T1 & is_alu_r) | (T2 & is_alu_r) | 
                      (T1 & is_alu_2op) | (T2 & is_alu_2op) |
                      (T1 & is_alu_i) | 
                      (T1 & is_md) | (T2 & is_md) |
                      (T1 & op_ld) | (T1 & op_st) | (T4 & op_st) | 
                      (T1 & op_br) | (T1 & op_jr) | (T2 & op_jal) | (T1 & op_out) | (T1 & op_mtivr);
    
    // Interrupt Hardware Signals
    assign EPCin = T_INT1;
    assign EPCout = (T1 & op_rfi);
    assign IVRin = (T1 & op_mtivr);
    assign IVRout = T_INT2;
    
    assign set_IE = (T1 & op_ei) | (T1 & op_rfi);
    assign clear_IE = (T1 & op_di) | T_INT1;

    // System Control & Routing
    assign PCjump = T4 & op_br;
    assign IRin = T0;
    assign Cout = (T2 & is_alu_i) | (T2 & op_ld) | (T2 & op_st) | (T3 & op_br);
    assign RYin = (T1 & is_alu_r) | (T1 & is_alu_2op) | (T1 & is_alu_i) | (T1 & is_md) | (T1 & op_ld) | (T1 & op_st) | (T2 & op_br);
    
    // Memory Routing
    assign MARin = (T3 & op_ld) | (T3 & op_st);
    assign RAMread = (T4 & op_ld);
    assign RAMwrite = (T5 & op_st);
    assign MDRread = (T4 & op_ld);

    assign CONin = (T1 & op_br);
    assign OutPortEnable = (T1 & op_out);
    assign InPortStrobe = (T1 & op_in);

    assign RZout = 1'b0;
    assign RBin = 1'b0;

    // 16-bit RinHI Mapping
    assign RinHI[0] = (T4 & is_md);
    assign RinHI[1] = (T3 & is_md);
    assign RinHI[2] = (T2 & is_md);
    assign RinHI[3] = (T2 & is_alu_r) | (T2 & is_alu_2op) | (T2 & is_alu_i) | (T2 & op_ld) | (T2 & op_st) | (T3 & op_br) | (T2 & is_md);
    // UPDATED PCin: Added T_INT2 (load ISR) and op_rfi (restore EPC)
    assign RinHI[4] = T0 | (T1 & op_jr) | (T2 & op_jal) | T_INT2 | (T1 & op_rfi);
    assign RinHI[5] = (T4 & op_ld) | (T4 & op_st);
    assign RinHI[15:6] = 10'b0;

    // 16-bit RoutHI Mapping
    assign RoutHI[0] = (T1 & op_mfhi);
    assign RoutHI[1] = (T1 & op_mflo);
    assign RoutHI[2] = (T4 & is_md);
    assign RoutHI[3] = (T3 & is_alu_r) | (T3 & is_alu_2op) | (T3 & is_alu_i) | (T3 & op_ld) | (T3 & op_st) | (T4 & op_br) | (T3 & is_md);
    // UPDATED PCout: Added T_INT1 (save PC to EPC)
    assign RoutHI[4] = T0 | (T2 & op_br) | (T1 & op_jal) | T_INT1;
    assign RoutHI[5] = (T5 & op_ld);
    assign RoutHI[6] = (T1 & op_in);
    assign RoutHI[15:7] = 9'b0;

    // ALU Control Signals
    assign ALUControl = 
        (op_add | op_addi | op_ld | op_st | op_br | op_ldi) ? 16'd12 :
        (op_sub) ? 16'd13 :
        (op_and | op_andi) ? 16'd1 :
        (op_or | op_ori) ? 16'd2 :
        (op_not) ? 16'd3 :
        (op_neg) ? 16'd6 :
        (op_rol) ? 16'd7 :
        (op_ror) ? 16'd8 :
        (op_shl) ? 16'd9 :
        (op_shr) ? 16'd10 :
        (op_shra) ? 16'd11 :
        (op_mul) ? 16'd14 :
        (op_div) ? 16'd15 :
        16'd0;

endmodule