`timescale 1ns / 10ps

// in, out

module tb();
    reg clock, clear;
    reg [15:0] ALUControl;

    reg IRin, MARin, RZout, RYin, RBin, PCjump, MDRread, CONin;
    reg GPR_Rin, GPR_Rout;
    reg [15:0] RinHI, RoutHI;

    reg Gra, Grb, Grc, BAout, Cout;
    reg RAMread, RAMwrite;
    reg InPortStrobe, OutPortEnable;

    parameter Default = 6'd0,
              C1_T0 = 6'd1, C1_T1 = 6'd2, C1_T2 = 6'd3, C1_T3 = 6'd4, C1_Hold = 6'd5,
              C2_T0 = 6'd6, C2_T1 = 6'd7, C2_T2 = 6'd8, C2_T3 = 6'd9, C2_Hold = 6'd10;

    reg [5:0] Present_state = Default;
    
    DataPath dp(
        .clock(clock), .clear(clear), .ALUControl(ALUControl),
        .GPR_Rin(GPR_Rin), .GPR_Rout(GPR_Rout), .IRin(IRin),
        .MARin(MARin), .RZout(RZout), .RYin(RYin), .RBin(RBin),
        .PCjump(PCjump), .MDRread(MDRread), .CONin(CONin), .RinHI(RinHI),
        .RoutHI(RoutHI), .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .BAout(BAout), .Cout(Cout), .RAMread(RAMread),
        .RAMwrite(RAMwrite), .InPortStrobe(InPortStrobe),
        .OutPortEnable(OutPortEnable)
    );

    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    initial begin
        $dumpfile("phase2/p7tb.vcd");
        $dumpvars(0, tb);
        
        clear = 1;
        ALUControl = 16'h0; RinHI = 16'h0; RoutHI = 16'h0;
        IRin = 0; MARin = 0; RZout = 0; RYin = 0; RBin = 0; PCjump = 0; CONin = 0;
        MDRread = 0; GPR_Rin = 0; GPR_Rout = 0;
        Gra = 0; Grb = 0; Grc = 0; BAout = 0; Cout = 0;
        RAMread = 0; RAMwrite = 0; InPortStrobe = 0; OutPortEnable = 0;

        // Load instructions into RAM 
        // Case 1: out R7 -> Ra=R7(0111). 
        dp.ram.memory[0] = 32'h03800000; 
        
        // Case 2: in R5 -> Ra=R5(0101).
        dp.ram.memory[4] = 32'h02800000; 

        #20 clear = 0;
        
        #600;
        $display("\n===============================================");
        $display("   INPUT/OUTPUT INSTRUCTION SIMULATION RESULTS");
        $display("===============================================");
        $display("Case 1 (out R7) | R7 preloaded with 0xCAFEBABE:");
        $display(" -> OutPort Final Value = %h (Expected: cafebabe)", dp.OutPortData);
        $display("Case 2 (in R5)  | InPort preloaded with 0xFACEB00C:");
        $display(" -> R5 Final Value      = %h (Expected: faceb00c)", dp.R5.q);
        $display("===============================================\n");
        $finish; 
    end

    // Sequential State Transition & Dynamic Register Preloading
    always @(negedge clock) begin
        case (Present_state)
            Default: if (!clear) begin 
                Present_state <= C1_T0; 
                dp.PC.pc_q <= 32'h0;
                dp.R7.q <= 32'hCAFEBABE; // Dummy data to write out
                dp.InPort.inport_q <= 32'hFACEB00C; // Dummy data to read in
                dp.R5.q <= 32'h0;
            end
            
            C1_T0: Present_state <= C1_T1; C1_T1: Present_state <= C1_T2; C1_T2: Present_state <= C1_T3;
            C1_T3: Present_state <= C1_Hold;
            
            C1_Hold: Present_state <= C2_T0; // Let PC flow naturally to 4
            
            C2_T0: Present_state <= C2_T1; C2_T1: Present_state <= C2_T2; C2_T2: Present_state <= C2_T3;
            C2_T3: Present_state <= C2_Hold;
            
            C2_Hold: Present_state <= C2_Hold; // Halt
        endcase
    end

    // Control Signal Assertions
    always @(Present_state) begin
        case (Present_state)
            Default, C1_Hold, C2_Hold: begin
                RinHI <= 16'h0; RoutHI <= 16'h0; MARin <= 0; IRin <= 0;
                RYin <= 0; RAMread <= 0; MDRread <= 0; Gra <= 0; Grb <= 0;
                BAout <= 0; Cout <= 0; GPR_Rin <= 0; GPR_Rout <= 0; 
                CONin <= 0; PCjump <= 0; ALUControl <= 16'd0;
                OutPortEnable <= 0; InPortStrobe <= 0;
            end
            
            // COMMON FETCH & DECODE
            C1_T0, C2_T0: begin // PCout, MARin, IncPC, Zin
                RoutHI[4] <= 1; MARin <= 1; RinHI[3] <= 1;
                #20 RoutHI[4] <= 0; MARin <= 0; RinHI[3] <= 0;
            end
            C1_T1, C2_T1: begin // Zlowout, PCin, Read, MDRin
                RoutHI[3] <= 1; RinHI[4] <= 1; RAMread <= 1; RinHI[5] <= 1; MDRread <= 1;
                #20 RoutHI[3] <= 0; RinHI[4] <= 0; RAMread <= 0; RinHI[5] <= 0; MDRread <= 0;
            end
            C1_T2, C2_T2: begin // MDRout, IRin
                RoutHI[5] <= 1; IRin <= 1; 
                #20 RoutHI[5] <= 0; IRin <= 0;
            end

            // OUT EXECUTION
            C1_T3: begin // Gra, Rout, Out.Port
                Gra <= 1; GPR_Rout <= 1; OutPortEnable <= 1; 
                #20 Gra <= 0; GPR_Rout <= 0; OutPortEnable <= 0;
            end

            // IN EXECUTION
            C2_T3: begin // InPortout, Gra, Rin
                RoutHI[6] <= 1; Gra <= 1; GPR_Rin <= 1; 
                #20 RoutHI[6] <= 0; Gra <= 0; GPR_Rin <= 0;
            end
        endcase
    end
endmodule