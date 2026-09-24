\# FPGA-Based Digital PID Controller



\## Overview



This project implements a digital Proportional-Integral-Derivative (PID) controller using Verilog HDL and Xilinx Vivado.



The objective is to develop a synthesizable FPGA-based control architecture capable of executing PID control operations in real time. The design is intended for digital control applications where deterministic and high-speed controller execution is required.



\## Project Objectives



\- Design a digital PID controller using Verilog HDL.

\- Implement the controller using FPGA-based digital logic.

\- Develop and verify the RTL design using Xilinx Vivado.

\- Study the implementation of proportional, integral, and derivative control terms in discrete time.

\- Develop a hardware-oriented control implementation suitable for real-time applications.



\## Control Structure



The PID controller is based on the discrete-time control law:



u\[k] = Kp e\[k] + Ki Σe\[k] + Kd(e\[k] - e\[k-1])



where:



\- `e\[k]` is the current control error.

\- `Kp` is the proportional gain.

\- `Ki` is the integral gain.

\- `Kd` is the derivative gain.

\- `u\[k]` is the controller output.



The controller operates on sampled digital signals and generates the corresponding control output using FPGA logic.



\## Implementation



\### Hardware



\- FPGA Platform: Xilinx FPGA

\- Digital Controller: PID Controller

\- RTL Language: Verilog HDL



\### Software



\- Xilinx Vivado

\- Verilog HDL

\- Vivado RTL Simulation

\- Synthesis and Implementation tools



\## Project Structure



```text

FPGA-Vivado-Projects/

│

├── README.md

├── .gitignore

│

├── digital\_pid\_cont\_vmc.xpr

│

└── digital\_pid\_cont\_vmc.srcs/

&#x20;   ├── sources\_1/

&#x20;   └── sim\_1/

