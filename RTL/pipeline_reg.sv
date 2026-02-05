//------------------------------------------------------------------------------
// Module: pipeline_reg
// Description:
//   Single-stage pipeline register implementing a standard valid/ready handshake.
//   The module buffers one data element, supports flow-through operation when
//   empty, and correctly handles backpressure without data loss or duplication.
//
//   - Accepts input data when in_valid && in_ready
//   - Presents stored data on the output with out_valid
//   - Holds data stable during backpressure (out_ready deasserted)
//   - Resets to a clean, empty state
//------------------------------------------------------------------------------

module pipeline_reg #(
    parameter int DATA_WIDTH = 32
)(
    input  logic                   clk,
    input  logic                   rst_n,

    // Input interface
    input  logic [DATA_WIDTH-1:0]  in_data,
    input  logic                   in_valid,
    output logic                   in_ready,

    // Output interface
    output logic [DATA_WIDTH-1:0]  out_data,
    output logic                   out_valid,
    input  logic                   out_ready
);

    // Internal storage for one pipeline stage
    logic [DATA_WIDTH-1:0] data_reg;
    logic                  valid_reg;

    // The pipeline can accept new data if:
    // - it is currently empty, or
    // - the existing data will be popped in the same cycle
    assign in_ready  = ~valid_reg || out_ready;

    // Output is valid whenever the internal register holds valid data
    assign out_valid = valid_reg;

    // Drive output data directly from the internal register
    assign out_data  = data_reg;

    // Sequential logic implementing push, pop, and flow-through behavior
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // On reset, clear the valid flag to indicate an empty pipeline
            valid_reg <= 1'b0;
        end else begin
            // Push operation (may occur with or without a simultaneous pop)
            if (in_valid && in_ready) begin
                data_reg  <= in_data;
                valid_reg <= 1'b1;
            end
            // Pop operation when no new data is being pushed
            else if (out_ready && valid_reg) begin
                valid_reg <= 1'b0;
            end
            // Otherwise, hold the current data and valid state
        end
    end

endmodule
