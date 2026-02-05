# OptoML Intern Task (Divya Darshan VR)
## Single-Stage Pipeline Register (Valid–Ready Handshake)

## Overview
- This repository contains a synthesizable SystemVerilog implementation of a **single-stage pipeline register** using a standard **valid/ready handshake**. The design safely buffers one data element, supports flow-through operation, and correctly handles backpressure without data loss or duplication.
- This task was developed as part of a practical RTL exercise for a ASIC Design internship role at OptoML.
  
---
## Design Description

### Interface Signals

| Signal      | Direction | Description                                   |
|------------|-----------|-----------------------------------------------|
| `in_valid` | Input     | Indicates that input data is valid            |
| `in_ready` | Output    | Indicates the pipeline can accept input data  |
| `in_data`  | Input     | Input data bus                                |
| `out_valid`| Output    | Indicates that output data is valid           |
| `out_ready`| Input     | Indicates downstream is ready to accept data  |
| `out_data` | Output    | Output data bus                               |

### Behavior
- Data is accepted when `in_valid && in_ready`
- Data is transferred to the output when `out_valid && out_ready`
- During backpressure (`out_valid=1, out_ready=0`), data is held stable
- Supports **flow-through** operation when empty and ready
- Resets to a clean, empty state

---
## RTL Implementation
- Fully synthesizable SystemVerilog
- One-entry storage (data register + valid register)
- No combinational loops or latches
- Single-clock synchronous reset

👉[You can click here to checkout the code](RTL)

---
## Verification
### Testbench Features
- Directed tests for:
  - Simple push/pop
  - Backpressure handling
  - Flow-through operation
  - Multiple sequential transfers
- Cycle-accurate monitoring
- Backpressure and drain behavior validation

👉 [You can click here to check out the testbench](TB/pipeline_reg_tb.sv)

---
### RTL Simulation
- Commands used (iverilog simulator)
```bash
iverilog -g2012 rtl/pipeline_reg.sv tb/pipeline_reg_tb.sv -o sim.out
vvp sim.out
gtkwave wave.vcd
```
**Terminal Screenshot**

[!rtl sim](../Images/terminal_ss.jpeg)

**Screenshot**: Waveform of Pipelined Register

[!rtl sim](../Images/gtkwave.jpeg)

---
## Synthesis
### Tool Used
```bash
Yosys 
```

- Commands Used:

```bash
#Invoke yosys shell
yosys

#Read verilog file
read_verilog -sv rtl/pipeline_reg.sv

#Synthesize the module
synth -top pipeline_reg

#Technology mapping
abc -liberty sky130_fd_sc_hd__tt_025C_1v80.lib

#To see the mapping of std cells
show

#To create the synthesized netlist
write_verilog synth/pipeline_reg_syn.v
```
👉[Synthesis reports and netlist are available in](Synth/)

**Terminal Screenshot** 

[synth](../Images/synth_1.jpeg)

[synth](../Images/synth_1.jpeg)


**Screenshot**: Synthesis schematic

[synth](../Images/synth_schematic_1.jpeg)

[synth](../Images/synth_schematic_2.jpeg)

---
### Key Takeaways

- Correct implementation of ready–valid handshake
- Proper backpressure handling
- Clean reset and drain behavior
- Verified both functionally and structurally

---
## Contact

- **Name**: Divya Darshan VR
- **College**: College of Engineering Guindy, Anna University
- **Dept** : B.E Electronics and Communication Engineering
- **Email**: [divyadarshanvr09@gmail.com](mailto:divya.darshan@example.com)  
- **Mobile**: +91-9092109353
- **LinkedIn**: (https://www.linkedin.com/in/divya-darshan-vr-2b4560289)  
- **Website / Portfolio**: (https://linktr.ee/Divya_Darshan_VR)
