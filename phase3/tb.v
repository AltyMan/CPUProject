`timescale 1ns / 10ps

module phase3_tb();
    reg clock;
    reg clear;
    reg stop;
    integer log_fd;

    DataPath dp(
        .clock(clock),
        .clear(clear),
        .stop(stop)
    );

    // Clock Generation
    initial begin
        clock = 0;
        forever #10 clock = ~clock; // 20ns period
    end

    // Main Simulation Block
    initial begin
        log_fd = $fopen("phase3/sim_log.txt", "w");
        if (log_fd == 0) begin
            $display("ERROR: Could not open phase3/sim_log.txt for writing.");
            $finish;
        end

        clear = 1;
        stop = 0;
        #40;
        clear = 0;
        
        // Failsafe Timeout (prevents infinite loops)
        #25000; 
        $display("Simulation Timeout Reached");
        $display("Final R14 = %h", dp.BusMuxInR14);
        $fdisplay(log_fd, "Simulation Timeout Reached");
        $fdisplay(log_fd, "Final R14 = %h", dp.BusMuxInR14);
        $fclose(log_fd);
        $finish;
    end

    // --- THE DIAGNOSTIC LOGGER ---
    // This block triggers on the falling edge of the clock to read stable signals
    always @(negedge clock) begin
        if (!clear) begin
            // 1. Log the start of a new instruction
            if (dp.CU.state == 3'd1) begin
                $display("\n[%0t ns] FETCH: PC = %03h | IR = %08h", $time, dp.BusMuxInPC, dp.IROut);
                $fdisplay(log_fd, "\n[%0t ns] FETCH: PC = %03h | IR = %08h", $time, dp.BusMuxInPC, dp.IROut);
            end
            
            // 2. Log the current state and bus value
            $display("[%0t ns] State T%0d | Bus = %8h | ALU_Sel = %0d", 
                     $time, dp.CU.state, dp.BusMuxOut, dp.ALUControl);
            $fdisplay(log_fd, "[%0t ns] State T%0d | Bus = %8h | ALU_Sel = %0d", 
                      $time, dp.CU.state, dp.BusMuxOut, dp.ALUControl);
                     
            // 3. Log General Purpose Register Writes
            if (dp.GPR_Rin) begin
                $display("REG WRITE: Latched %8h (Renable mask: %b)", dp.BusMuxOut, dp.Renable);
                $fdisplay(log_fd, "REG WRITE: Latched %8h (Renable mask: %b)", dp.BusMuxOut, dp.Renable);
            end
            
            // 4. Log Memory Writes
            if (dp.RAMwrite) begin
                $display("MEM WRITE: Addr [%h] <= %h", dp.MAROut, dp.BusMuxOut);
                $fdisplay(log_fd, "MEM WRITE: Addr [%h] <= %h", dp.MAROut, dp.BusMuxOut);
            end

            // 5. Log Branching
            if (dp.PCjump) begin
                $display("BRANCH TAKEN: Next PC = %h", dp.BusMuxOut);
                $fdisplay(log_fd, "BRANCH TAKEN: Next PC = %h", dp.BusMuxOut);
            end

            // 6. Catch the Halt Instruction
            if (dp.CU.op_halt && dp.CU.state == 3'd1) begin
                $display("\nHALT INSTRUCTION");
                $display("Final R14 = %h\n", dp.BusMuxInR14);
                $fdisplay(log_fd, "\n========================================================");
                $fdisplay(log_fd, "\nHALT INSTRUCTION");
                $fdisplay(log_fd, "Final R14 = %h\n", dp.BusMuxInR14);
                $fclose(log_fd);
                $finish;
            end
        end
    end
endmodule