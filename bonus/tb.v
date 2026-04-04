`timescale 1ns / 10ps

module bonus_tb();
    reg clock;
    reg clear;
    reg stop;
    reg IRQ;
    
    reg [31:0] ExternalIn;
    wire [31:0] ExternalOut;
    wire run;
    
    integer log_fd;
    reg [47:0] state_name;

    DataPath dp(
        .clock(clock),
        .clear(clear),
        .stop(stop),
        .IRQ(IRQ), 
        .InPortData(ExternalIn),
        .OutPortData(ExternalOut),
        .run(run)
    );

    initial begin
        clock = 0;
        forever #10 clock = ~clock; 
    end

    task print_cpu_state;
        begin
            $display("R0:  %8h | R1:  %8h", dp.resultR0, dp.BusMuxInR1);
            $display("R2:  %8h | R3:  %8h", dp.BusMuxInR2, dp.BusMuxInR3);
            $display("R4:  %8h | R5:  %8h", dp.BusMuxInR4, dp.BusMuxInR5);
            $display("R6:  %8h | R7:  %8h", dp.BusMuxInR6, dp.BusMuxInR7);
            $display("R8:  %8h | R9:  %8h", dp.BusMuxInR8, dp.BusMuxInR9);
            $display("R10: %8h | R11: %8h", dp.BusMuxInR10, dp.BusMuxInR11);
            $display("R12: %8h | R13: %8h", dp.BusMuxInR12, dp.BusMuxInR13);
            $display("R14: %8h | R15: %8h", dp.BusMuxInR14, dp.BusMuxInR15);
            
            // UPDATED: Now includes the IVR register!
            $display("HI:  %8h | LO:  %8h | EPC: %8h | IVR: %8h | IE: %b", dp.BusMuxInHI, dp.BusMuxInLO, dp.BusMuxInEPC, dp.BusMuxInIVR, dp.IE_out);
            $display("MAR: %8h | MDR: %8h", {23'b0, dp.MAROut}, dp.Mdataout);
            
            $display("MEM[0x88]: %8h | MEM[0x89]: %8h | MEM[0xA3]: %8h\n", 
                     dp.l1_dcache.memory[9'h088], dp.l1_dcache.memory[9'h089], dp.l1_dcache.memory[9'h0a3]);

            $fdisplay(log_fd, "R0:  %8h | R1:  %8h", dp.resultR0, dp.BusMuxInR1);
            $fdisplay(log_fd, "R2:  %8h | R3:  %8h", dp.BusMuxInR2, dp.BusMuxInR3);
            $fdisplay(log_fd, "R4:  %8h | R5:  %8h", dp.BusMuxInR4, dp.BusMuxInR5);
            $fdisplay(log_fd, "R6:  %8h | R7:  %8h", dp.BusMuxInR6, dp.BusMuxInR7);
            $fdisplay(log_fd, "R8:  %8h | R9:  %8h", dp.BusMuxInR8, dp.BusMuxInR9);
            $fdisplay(log_fd, "R10: %8h | R11: %8h", dp.BusMuxInR10, dp.BusMuxInR11);
            $fdisplay(log_fd, "R12: %8h | R13: %8h", dp.BusMuxInR12, dp.BusMuxInR13);
            $fdisplay(log_fd, "R14: %8h | R15: %8h", dp.BusMuxInR14, dp.BusMuxInR15);
            $fdisplay(log_fd, "HI:  %8h | LO:  %8h | EPC: %8h | IVR: %8h | IE: %b", dp.BusMuxInHI, dp.BusMuxInLO, dp.BusMuxInEPC, dp.BusMuxInIVR, dp.IE_out);
            $fdisplay(log_fd, "MAR: %8h | MDR: %8h", {23'b0, dp.MAROut}, dp.Mdataout);
            $fdisplay(log_fd, "MEM[0x88]: %8h | MEM[0x89]: %8h | MEM[0xA3]: %8h | MEM[0x77]: %8h\n", 
                      dp.l1_dcache.memory[9'h088], dp.l1_dcache.memory[9'h089], dp.l1_dcache.memory[9'h0a3], dp.l1_dcache.memory[9'h077]);
        end
    endtask

    initial begin
        $dumpfile("bonus/tb.vcd");
        $dumpvars(0, bonus_tb);
        log_fd = $fopen("bonus/sim_log.txt", "w");
        if (log_fd == 0) begin
            $display("ERROR: Could not open bonus/sim_log.txt for writing.");
            $finish;
        end

        clear = 1; stop = 0; IRQ = 0;
        ExternalIn = 32'h000001E0; 
        
        repeat(4) @(posedge clock);
        
        $display("Initial States:");
        $fdisplay(log_fd, "Initial States:");
        print_cpu_state();
        
        clear = 0;
        
        wait(dp.IE_out == 1'b1);
        repeat(50) @(posedge clock);
        
        $display("\n[%0t ns] --- CHANGING SWITCHES TO 0xAA AND FIRING IRQ ---\n", $time);
        $fdisplay(log_fd, "\n[%0t ns] --- CHANGING SWITCHES TO 0xAA AND FIRING IRQ ---\n", $time);
        
        ExternalIn = 32'h000001AA; 
        
        IRQ = 1;
        wait(dp.CU.state == 3'd6); 
        IRQ = 0;
    end

    always @(ExternalOut) begin
        if (!clear) begin
            $display("\n>>> SEVEN SEGMENT DISPLAY UPDATED: %02h <<<\n", ExternalOut[7:0]);
            $fdisplay(log_fd, "\n>>> SEVEN SEGMENT DISPLAY UPDATED: %02h <<<\n", ExternalOut[7:0]);
        end
    end
    
    always @(posedge clock) begin
        if (!clear) begin
            if (dp.CU.state == 3'd6) begin
                $display("\n[%0t ns] >>> ENTERING HARDWARE INTERRUPT STATE T_INT1 <<<", $time);
                $display("           Saving PC (%08h) into EPC. Disabling future interrupts.", dp.BusMuxInPC);
                $fdisplay(log_fd, "\n[%0t ns] >>> ENTERING HARDWARE INTERRUPT STATE T_INT1 <<<", $time);
                $fdisplay(log_fd, "           Saving PC (%08h) into EPC. Disabling future interrupts.", dp.BusMuxInPC);
            end
            
            if (dp.CU.state == 3'd7) begin
                $display("[%0t ns] >>> ENTERING HARDWARE INTERRUPT STATE T_INT2 <<<", $time);
                // UPDATED: Dynamically prints the IVR!
                $display("           Loading IVR Vector (%08h) into PC.", dp.BusMuxInIVR); 
                $fdisplay(log_fd, "[%0t ns] >>> ENTERING HARDWARE INTERRUPT STATE T_INT2 <<<", $time);
                $fdisplay(log_fd, "           Loading IVR Vector (%08h) into PC.", dp.BusMuxInIVR);
            end
            
            if (dp.CU.op_rfi && dp.CU.state == 3'd1) begin
                $display("\n[%0t ns] >>> EXECUTING RFI (Return From Interrupt) <<<", $time);
                $display("           Restoring PC from EPC (%08h). Re-enabling interrupts.", dp.BusMuxInEPC);
                $fdisplay(log_fd, "\n[%0t ns] >>> EXECUTING RFI (Return From Interrupt) <<<", $time);
                $fdisplay(log_fd, "           Restoring PC from EPC (%08h). Re-enabling interrupts.", dp.BusMuxInEPC);
            end
            
            if (dp.set_IE) begin
                $display("[%0t ns] *** IE FLAG SET TO 1 (Interrupts Enabled) ***", $time);
                $fdisplay(log_fd, "[%0t ns] *** IE FLAG SET TO 1 (Interrupts Enabled) ***", $time);
            end
            if (dp.clear_IE) begin
                $display("[%0t ns] *** IE FLAG CLEARED TO 0 (Interrupts Masked) ***", $time);
                $fdisplay(log_fd, "[%0t ns] *** IE FLAG CLEARED TO 0 (Interrupts Masked) ***", $time);
            end
        end
    end

    always @(negedge clock) begin
        if (!clear) begin
            if (dp.CU.state == 3'd1) begin
                $display("\n[%0t ns] FETCH: PC = %03h | IR = %08h", $time, dp.BusMuxInPC, dp.IROut);
                $fdisplay(log_fd, "\n[%0t ns] FETCH: PC = %03h | IR = %08h", $time, dp.BusMuxInPC, dp.IROut);
            end
            
            begin
                case (dp.CU.state)
                    3'd0: state_name = "T0    ";
                    3'd1: state_name = "T1    ";
                    3'd2: state_name = "T2    ";
                    3'd3: state_name = "T3    ";
                    3'd4: state_name = "T4    ";
                    3'd5: state_name = "T5    ";
                    3'd6: state_name = "T_INT1";
                    3'd7: state_name = "T_INT2";
                endcase
            end
            
            $display("[%0t ns] State %s | Bus = %8h | IE = %b | Latch = %b", 
                     $time, state_name, dp.BusMuxOut, dp.IE_out, dp.irq_latched);
            $fdisplay(log_fd, "[%0t ns] State %s | Bus = %8h | IE = %b | Latch = %b", 
                      $time, state_name, dp.BusMuxOut, dp.IE_out, dp.irq_latched);
                     
            if (dp.GPR_Rin) begin
                $display("REG WRITE: Latched %8h (Renable mask: %b)", dp.BusMuxOut, dp.Renable);
                $fdisplay(log_fd, "REG WRITE: Latched %8h (Renable mask: %b)", dp.BusMuxOut, dp.Renable);
            end
            
            if (dp.RAMwrite) begin
                $display("MEM WRITE: Addr [%h] <= %h", dp.MAROut, dp.Mdataout);
                $fdisplay(log_fd, "MEM WRITE: Addr [%h] <= %h", dp.MAROut, dp.Mdataout);
            end

            if (dp.CU.op_halt && dp.CU.state == 3'd1) begin
                $display("\nHALT INSTRUCTION REACHED");
                $fdisplay(log_fd, "\nHALT INSTRUCTION REACHED");
                
                $display("\nFinal States:");
                $fdisplay(log_fd, "\nFinal States:");
                print_cpu_state();
                
                $fclose(log_fd);
                $finish;
            end
        end
    end
endmodule