// Code your design here
`timescale 1ns/1ps
// uart_rx.v — Verilog-2005, 8-N-1 UART receiver, ≤10 outputs, 1 clk
// Inputs:  clk, rx
// Outputs: rx_data[7:0], rx_valid, framing_error   (total outputs = 10)

module uart_rx #(
    parameter integer CLK_FREQ  = 50000000, // Hz
    parameter integer BAUD_RATE = 115200
)(
    input        clk,               // single clock
    input        rx,                // serial input
    output reg [7:0] rx_data,       // received byte
    output reg       rx_valid,      // 1 clk pulse when byte ready
    output reg       framing_error  // asserted if stop bit not '1'
);

    // ------------------------------------------
    // Internal power-on reset (no external reset)
    // ------------------------------------------
    reg [3:0] por_cnt = 4'd0;
    wire      por_done = por_cnt[3];
    wire      rst_i    = ~por_done;

    always @(posedge clk) begin
        if (!por_done) por_cnt <= por_cnt + 4'd1;
    end

    // ------------------------------------------
    // Parameters for timing
    // ------------------------------------------
    localparam integer CLKS_PER_BIT  = CLK_FREQ / BAUD_RATE;   // ~434 @ 50MHz/115200
    localparam integer HALF_BIT_CLKS = CLKS_PER_BIT/2;

    // ------------------------------------------
    // 2-FF synchronizer for 'rx'
    // ------------------------------------------
    reg rx_meta, rx_sync;
    always @(posedge clk) begin
        rx_meta <= rx;
        rx_sync <= rx_meta;
    end

    // ------------------------------------------
    // FSM
    // ------------------------------------------
    localparam [1:0]
        S_IDLE  = 2'b00,
        S_START = 2'b01,
        S_DATA  = 2'b10,
        S_STOP  = 2'b11;

    reg [1:0] state;
    reg [15:0] clk_count;   // wide enough for CLKS_PER_BIT
    reg [2:0]  bit_idx;     // 0..7
    reg [7:0]  shreg;

    // ------------------------------------------
    // Sequential logic
    // ------------------------------------------
    always @(posedge clk) begin
        if (rst_i) begin
            state          <= S_IDLE;
            clk_count      <= 16'd0;
            bit_idx        <= 3'd0;
            shreg          <= 8'd0;
            rx_data        <= 8'd0;
            rx_valid       <= 1'b0;
            framing_error  <= 1'b0;
        end else begin
            rx_valid <= 1'b0; // default (one-cycle pulse when byte completes)
            case (state)
                S_IDLE: begin
                    framing_error <= 1'b0;
                    clk_count     <= 16'd0;
                    bit_idx       <= 3'd0;
                    if (rx_sync == 1'b0) begin // start edge
                        state     <= S_START;
                        clk_count <= 16'd0;
                    end
                end

                // Wait half a bit, then re-sample to confirm a valid start bit.
                S_START: begin
                    if (clk_count < HALF_BIT_CLKS) begin
                        clk_count <= clk_count + 16'd1;
                    end else begin
                        if (rx_sync == 1'b0) begin
                            // Good start bit → move to data; align to full bit periods
                            clk_count <= 16'd0;
                            bit_idx   <= 3'd0;
                            state     <= S_DATA;
                        end else begin
                            // False start
                            state <= S_IDLE;
                        end
                    end
                end

                // Sample each data bit at the middle of its bit window
                S_DATA: begin
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 16'd1;
                    end else begin
                        clk_count <= 16'd0;
                        shreg[bit_idx] <= rx_sync; // LSB-first
                        if (bit_idx < 3'd7) begin
                            bit_idx <= bit_idx + 3'd1;
                        end else begin
                            state   <= S_STOP;
                        end
                    end
                end

                // Sample stop bit; if not '1', flag framing error
                S_STOP: begin
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 16'd1;
                    end else begin
                        clk_count <= 16'd0;
                        rx_data   <= shreg;
                        rx_valid  <= 1'b1;
                        framing_error <= (rx_sync != 1'b1);
                        state     <= S_IDLE;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule
