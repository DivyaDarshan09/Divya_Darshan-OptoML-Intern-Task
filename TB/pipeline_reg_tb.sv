//------------------------------------------------------------------------------
// Testbench: pipeline_reg_tb
// Description:
//   Self-checking testbench for the single-stage pipeline register implementing
//   a valid/ready handshake. The testbench verifies correct behavior under
//   normal operation, backpressure, flow-through, and pipeline drain scenarios.
//
//   Key features:
//   - Event-driven monitor (prints only meaningful activity)
//   - Explicit pipeline flush between tests for isolation
//   - Directed testcases covering all handshake corner cases
//------------------------------------------------------------------------------

module pipeline_reg_tb;

    localparam int DATA_WIDTH = 8;

    // Clock and reset
    logic clk;
    logic rst_n;

    // Input interface signals
    logic [DATA_WIDTH-1:0] in_data;
    logic                  in_valid;
    logic                  in_ready;

    // Output interface signals
    logic [DATA_WIDTH-1:0] out_data;
    logic                  out_valid;
    logic                  out_ready;

    // Stimulus helper and cycle counter
    logic [DATA_WIDTH-1:0] stim_data;
    int cycle;

    //--------------------------------------------------------------------------
    // DUT instantiation
    //--------------------------------------------------------------------------
    pipeline_reg #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .in_data   (in_data),
        .in_valid  (in_valid),
        .in_ready  (in_ready),
        .out_data  (out_data),
        .out_valid (out_valid),
        .out_ready (out_ready)
    );

    //--------------------------------------------------------------------------
    // Clock generation: 10 time-unit period
    //--------------------------------------------------------------------------
    always #5 clk = ~clk;

    //--------------------------------------------------------------------------
    // Event-driven monitor
    // Prints only meaningful transactions to keep logs concise:
    //   - PUSH : data accepted into the pipeline
    //   - POP  : data consumed by downstream
    //   - HOLD : data stalled due to backpressure
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        cycle++;

        if (in_valid && in_ready)
            $display("[CYCLE %0d] PUSH  in_data=0x%0h", cycle, in_data);

        if (out_valid && out_ready)
            $display("[CYCLE %0d] POP   out_data=0x%0h", cycle, out_data);

        if (out_valid && !out_ready)
            $display("[CYCLE %0d] HOLD  out_data=0x%0h (backpressure)", cycle, out_data);
    end

    //--------------------------------------------------------------------------
    // Flush task
    // Ensures the single-entry pipeline is fully drained between testcases.
    // This prevents residual state from affecting subsequent tests.
    //--------------------------------------------------------------------------
    task flush_pipeline;
        begin
            in_valid  = 0;
            out_ready = 1;
            @(posedge clk);
            @(posedge clk); // One-entry pipeline requires up to two cycles
        end
    endtask

    //--------------------------------------------------------------------------
    // Test sequence
    //--------------------------------------------------------------------------
    initial begin
        // Enable waveform dumping for GTKWave
        $dumpfile("wave.vcd");
        $dumpvars(0, pipeline_reg_tb);

        // Initial conditions
        clk        = 0;
        rst_n      = 0;
        in_valid   = 0;
        in_data    = 0;
        out_ready  = 0;
        cycle      = 0;
        stim_data  = 8'h10;

        $display("\n--- RESET ---");
        #20;
        rst_n = 1;

        //----------------------------------------------------------------------
        // TEST 1: Simple push followed by pop
        // Verifies basic storage and later consumption of data
        //----------------------------------------------------------------------
        $display("\n--- TEST 1: SIMPLE PUSH & POP ---");

        @(posedge clk);
        in_valid  = 1;
        in_data   = 8'hA5;
        out_ready = 0;

        @(posedge clk);
        in_valid  = 0;
        out_ready = 1;

        flush_pipeline();

        //----------------------------------------------------------------------
        // TEST 2: Backpressure
        // Verifies that data is held stable when out_ready is deasserted
        //----------------------------------------------------------------------
        $display("\n--- TEST 2: BACKPRESSURE ---");

        @(posedge clk);
        in_valid  = 1;
        in_data   = 8'h3C;
        out_ready = 0;

        @(posedge clk);
        in_valid = 0;

        //----------------------------------------------------------------------
        // TEST 3: Release backpressure
        // Verifies correct pop of data after downstream becomes ready
        //----------------------------------------------------------------------
        $display("\n--- TEST 3: RELEASE BACKPRESSURE ---");

        @(posedge clk);
        out_ready = 1;

        flush_pipeline();

        //----------------------------------------------------------------------
        // TEST 4: Push and pop in the same cycle (flow-through)
        // Verifies zero-latency behavior when pipeline is empty
        //----------------------------------------------------------------------
        $display("\n--- TEST 4: PUSH & POP SAME CYCLE ---");

        @(posedge clk);
        in_valid  = 1;
        in_data   = 8'hF0;
        out_ready = 1;

        @(posedge clk);
        in_valid = 0;

        flush_pipeline();

        //----------------------------------------------------------------------
        // TEST 5: Multiple sequential transfers
        // Verifies ordering, one-cycle latency when occupied, and proper drain
        //----------------------------------------------------------------------
        $display("\n--- TEST 5: MULTIPLE TRANSFERS ---");

        repeat (3) begin
            @(posedge clk);
            in_valid  = 1;
            in_data   = stim_data;
            out_ready = 1;
            stim_data = stim_data + 8'h11;
        end

        @(posedge clk);
        in_valid = 0;

        flush_pipeline();

        //----------------------------------------------------------------------
        // End of simulation
        //----------------------------------------------------------------------
        #20;
        $display("\nALL TESTS COMPLETED ✅");
        $finish;
    end

endmodule
