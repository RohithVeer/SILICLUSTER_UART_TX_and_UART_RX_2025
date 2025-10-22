`timescale 1ns/1ps
module uart_tx_tb;
    reg        clk = 1'b0;
    reg        tx_start;
    reg [7:0]  tx_data;
    wire       tx, tx_busy;

    // 50 MHz clock
    always #10 clk = ~clk;

    uart_tx #(.CLK_FREQ(50000000), .BAUD_RATE(115200)) dut (
        .clk(clk),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);

        // Wait for internal POR to complete (~8 cycles)
        tx_start = 1'b0;
        tx_data  = 8'h00;
        #(200);  // safe margin

        // Send 0xA5
        tx_data  = 8'hA5;
        tx_start = 1'b1; #(20); tx_start = 1'b0;
        wait (!tx_busy); #(200);

        // Send 0x3C
        tx_data  = 8'h3C;
        tx_start = 1'b1; #(20); tx_start = 1'b0;
        wait (!tx_busy); #(200);

        $finish;
    end
endmodule