# Collision_PUF

Summer research project at **VLSI Design Institute**, Yuquan Campus, Zhejiang University.  

This is a FPGA Implementation of Collision based SRAM PUFs.  
Read Write Collision (RWC) PUF woulld base on the literature by Ihsan Cicek and Ahmad Al Khas:
[A new read–write collision-based SRAM PUF implemented on Xilinx FPGAs](https://link.springer.com/article/10.1007/s13389-021-00281-8).

UART implementation based on [(verilog)UART协议详讲与实现](https://zhuanlan.zhihu.com/p/549612117). (NOT used yet)

## Hardware and Settings
### FPGA Evaluation Board
Xilinx VC707 | Virtex-7 XC7VX485TFFG1761-2
### Serical COM Port: UART
- Baud Rate: 9600  
- Parity Bit: Even
- Stop Bit: 1
- Data Length: 8
### IP Core Settings
#### Clock
- Input: 100MHZ Differential Clock (System Clock)
- Output: **500MHZ** Single Port Clock
#### Block RAM Generator
- True Dual Port Mode (TDP)
- Data Width: 32
- Data Depth: 1024
- Read & Write Delay: 1 cycle (No primitive register enabled)


## Developing Progress
- [ ] Read-Write Collision PUF
    - [x] Single Port, Time Delay 1 cycle: **FAILED: All data written successfully** 
    - [ ] Single Port, Time Delay 0.5 cycle: **IN PROGRESS**
    - [ ] Dual Port, Read Write Seperated experiment
- [ ] Dual-Port Write Collision PUF