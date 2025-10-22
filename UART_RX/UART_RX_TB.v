`timescale 1ns/1ps
module uart_rx_tb;

    // Parameters matching TX
    localparam integer CLK_FREQ  = 50000000;
    localparam integer BAUD_RATE = 115200;
    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE; // ~434 at 50MHz

    reg clk = 1'b0;
    reg rx  = 1'b1; // idle high
    wire [7:0] rx_data;
    wire       rx_valid;
    wire       framing_error;

    // 50 MHz clock (20 ns period)
    always #10 clk = ~clk;

    // DUT
    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) dut (
        .clk(clk),
        .rx(rx),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .framing_error(framing_error)
    );

    // Task to transmit one UART frame on 'rx' (start + 8 data + stop)
    task send_byte;
        input [7:0] b;
        integer i, k;
        begin
            // start bit
            rx = 1'b0;
            for (k=0; k<CLKS_PER_BIT; k=k+1) @(posedge clk);
            // data bits LSB-first
            for (i=0; i<8; i=i+1) begin
                rx = b[i];
                for (k=0; k<CLKS_PER_BIT; k=k+1) @(posedge clk);
            end
            // stop bit
            rx = 1'b1;
            for (k=0; k<CLKS_PER_BIT; k=k+1) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, uart_rx_tb);

        // idle a bit (also lets internal POR finish)
        repeat (200) @(posedge clk);

        // Send two bytes that we used in TX tests
        send_byte(8'hA5); // expect rx_data=0xA5
        repeat (50) @(posedge clk);

        send_byte(8'h3C); // expect rx_data=0x3C
        repeat (50) @(posedge clk);

        // Check results (simple console prints)
        @(posedge clk);
        $display("Last rx_data=0x%0h, rx_valid=%0d, framing_error=%0d", rx_data, rx_valid, framing_error);

        // Let waves settle then finish
        repeat (200) @(posedge clk);
        $finish;
    end
endmodule
