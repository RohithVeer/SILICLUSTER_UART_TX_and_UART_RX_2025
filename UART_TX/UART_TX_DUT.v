`timescale 1ns/1ps
// uart_tx.v — Verilog-2005, 8-N-1 UART transmitter, ≤10 inputs (no external reset)

module uart_tx #(
    parameter integer CLK_FREQ  = 50000000, // Hz
    parameter integer BAUD_RATE = 115200
)(
    input        clk,         // 1 clock input
    input        tx_start,    // 1 control input
    input  [7:0] tx_data,     // 8 data inputs  -> total inputs = 10
    output reg   tx,          // serial line (idle = 1)
    output reg   tx_busy      // high during transmission
);

    // ----------------------------------------------------------------
    // Power-On Reset (POR): hold internal reset for a few cycles
    // ----------------------------------------------------------------
    reg [3:0] por_cnt = 4'd0;
    wire      por_done = por_cnt[3];      // becomes 1 after 8 cycles
    wire      rst_i    = ~por_done;       // internal active-high reset

    always @(posedge clk) begin
        if (!por_done)
            por_cnt <= por_cnt + 4'd1;
    end

    // ----------------------------------------------------------------
    // Baud timing
    // ----------------------------------------------------------------
    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [15:0] clk_count;
    reg [2:0]  bit_index;     // 0..7
    reg [7:0]  tx_shift_reg;

    // FSM
    localparam [1:0]
        S_IDLE  = 2'b00,
        S_START = 2'b01,
        S_DATA  = 2'b10,
        S_STOP  = 2'b11;

    reg [1:0] state;

    // Outputs default
    // (We fully drive them in the sequential block below.)

    // ----------------------------------------------------------------
    // Sequential logic
    // ----------------------------------------------------------------
    always @(posedge clk) begin
        if (rst_i) begin
            state       <= S_IDLE;
            tx          <= 1'b1;   // idle line high
            tx_busy     <= 1'b0;
            clk_count   <= 16'd0;
            bit_index   <= 3'd0;
            tx_shift_reg<= 8'd0;
        end else begin
            case (state)
                S_IDLE: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                    clk_count <= 16'd0;
                    if (tx_start) begin
                        tx_shift_reg <= tx_data;
                        state        <= S_START;
                        tx_busy      <= 1'b1;
                    end
                end

                S_START: begin
                    tx <= 1'b0; // start bit (0)
                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count <= clk_count + 16'd1;
                    else begin
                        clk_count <= 16'd0;
                        bit_index <= 3'd0;
                        state     <= S_DATA;
                    end
                end

                S_DATA: begin
                    tx <= tx_shift_reg[bit_index]; // LSB-first
                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count <= clk_count + 16'd1;
                    else begin
                        clk_count <= 16'd0;
                        if (bit_index < 3'd7)
                            bit_index <= bit_index + 3'd1;
                        else
                            state <= S_STOP;
                    end
                end

                S_STOP: begin
                    tx <= 1'b1; // stop bit (1)
                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count <= clk_count + 16'd1;
                    else begin
                        state    <= S_IDLE;
                        tx_busy  <= 1'b0;
                    end
                end

                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
