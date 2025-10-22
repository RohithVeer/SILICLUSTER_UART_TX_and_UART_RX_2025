# SILICLUSTER 2025 — UART Transmitter (TX) & Receiver (RX)

### 👤 Author
**Rohith Mudigonda**  
Hardware Engineer | Ilensys Technologies  
GitHub: [RohithVeer](https://github.com/RohithVeer)

---

## 🔧 Project Overview
This repository includes two Verilog modules — **UART Transmitter (TX)** and **UART Receiver (RX)** — designed and verified for **Silicluster 2025** fabrication using the **SkyWater 130 nm PDK**.  
Both modules meet all design, verification, and layout requirements.

---

## 📘 Module Details

### 🟣 UART Transmitter (TX)
- **Function:** Converts 8-bit parallel data into serial format with start/stop bits  
- **Inputs:** `clk`, `rst`, `tx_start`, `tx_data[7:0]`  
- **Outputs:** `tx`, `tx_busy`  
- **Baud Rate:** 115200 bps | **Clock:** 50 MHz  
- **Gate Count:** ~150  
- **Simulation:** [EDAPlayground – UART TX](https://www.edaplayground.com/x/bCGt)

### 🟢 UART Receiver (RX)
- **Function:** Reconstructs received serial data into parallel 8-bit data  
- **Inputs:** `clk`, `rx`  
- **Outputs:** `rx_data[7:0]`, `rx_valid`, `framing_error`  
- **Baud Rate:** 115200 bps | **Clock:** 50 MHz  
- **Gate Count:** ~258  
- **Simulation:** [EDAPlayground – UART RX](https://www.edaplayground.com/x/ghDc)

---

## ⚙️ Silicluster Compliance Checklist

| Specification               | Status | Notes |
|------------------------------|:------:|-------|
| Max area (150×150 µm)        | ✅ | Verified via OpenLane |
| Max 10 inputs / 10 outputs   | ✅ | TX: 4 I/O, RX: 10 I/O |
| Single clock domain          | ✅ | Both modules |
| Verilog 2005 compliant       | ✅ | No SystemVerilog used |
| No loops (for/generate)      | ✅ | FSM-based sequential design |
| Gate count ≤ 500             | ✅ | TX ~150, RX ~258 |
| Functional testbench         | ✅ | Verified on EDAPlayground |
| SkyWater 130 nm PDK          | ✅ | Fabrication compatible |

---

## 💻 Local Simulation Commands

### UART TX
```bash
cd UART_TX
iverilog -g2005 UART_TX_DUT.v UART_TESTBENCH.v -o uart_tx_tb.out
vvp uart_tx_tb.out
gtkwave uart_tx.vcd
