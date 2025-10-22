# SILICLUSTER 2025 — UART Transmitter (TX) & Receiver (RX)

---

## Project Overview
This repository includes two Verilog modules — **UART Transmitter (TX)** and **UART Receiver (RX)** — designed and verified for **Silicluster 2025** fabrication using the **SkyWater 130 nm PDK**.  
Both modules meet all design, verification, and layout requirements.

---

## Module Details

### UART Transmitter (TX)
- **Function:** Converts 8-bit parallel data into serial format with start/stop bits  
- **Inputs:** `clk`, `rst`, `tx_start`, `tx_data[7:0]`  
- **Outputs:** `tx`, `tx_busy`  
- **Baud Rate:** 115200 bps | **Clock:** 50 MHz  
- **Gate Count:** ~150  
- **Simulation:** [EDAPlayground – UART TX](https://www.edaplayground.com/x/bCGt)

### UART Receiver (RX)
- **Function:** Reconstructs received serial data into parallel 8-bit data and detects framing errors  
- **Inputs:** `clk`, `rx`  
- **Outputs:** `rx_data[7:0]`, `rx_valid`, `framing_error`  
- **Baud Rate:** 115200 bps | **Clock:** 50 MHz  
- **Gate Count:** ~258  
- **Simulation:** [EDAPlayground – UART RX](https://www.edaplayground.com/x/ghDc)

---

## Silicluster Compliance Checklist

| Specification               | Status | Notes |
|------------------------------|:------:|-------|
| Max area (150×150 µm)        | ✅ Pass | Verified via OpenLane |
| Max 10 inputs / 10 outputs   | ✅ Pass | TX 4 I/O, RX 10 I/O |
| Single clock domain          | ✅ Pass | Both modules |
| Verilog 2005 compliant       | ✅ Pass | No SystemVerilog constructs |
| No loops (for/generate)      | ✅ Pass | FSM-based design |
| Gate count ≤ 500             | ✅ Pass | TX ≈ 150, RX ≈ 258 |
| Functional testbench included| ✅ Pass | Verified on EDAPlayground |
| SkyWater 130 nm PDK          | ✅ Pass | Fabrication compatible |

---

## Local Simulation Commands

### UART TX

-  cd UART_TX
- iverilog -g2005 UART_TX_DUT.v UART_TESTBENCH.v -o uart_tx_tb.out
- vvp uart_tx_tb.out
- gtkwave uart_tx.vcd


---

### UART RX

 - cd UART_RX
 - iverilog -g2005 UART_RX.v UART_RX_TB.v -o uart_rx_tb.out
 - vvp uart_rx_tb.out
 - gtkwave uart_rx.vcd


---

## Design & Verification Flow
- **RTL Design:** Verilog-2005 using FSM (finite-state machine)  
- **Simulation Tools:** Icarus Verilog and GTKWave  
- **Verification:** Functional verification via EDAPlayground  
- **Physical Design:** OpenLane environment with Sky130 PDK  
- **Documentation:** Includes timing, area, and waveform verification reports  

---

## Submission Details
- **Submission Email:** silicluster@gmail.com  
- **Deadline:** Sunday, August 3, 2025  
- **Technology:** SkyWater 130 nm (Sky130 PDK)

---

## License
This project is released under the **MIT License** — free for academic and open-source use.  
Refer to the `LICENSE` file for details.

---

## Outcome
Both **UART TX** and **UART RX** modules are fully verified, silicon-ready, and compliant with all **Silicluster 2025** and **Sky130 PDK** requirements.  
They serve as a complete, open-source UART subsystem suitable for academic and fabrication-grade projects.
