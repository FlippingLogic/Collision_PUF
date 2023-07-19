# Collision_PUF

Summer research project at **VLSI Design Institute**, Yuquan Campus, Zhejiang University.  

This is a FPGA Implementation of Collision based SRAM PUFs.  
Read Write Collision (RWC) PUF woulld base on the literature by Ihsan Cicek and Ahmad Al Khas:
[A new read–write collision-based SRAM PUF implemented on Xilinx FPGAs](https://link.springer.com/article/10.1007/s13389-021-00281-8).

UART implementation based on [(verilog)UART协议详讲与实现](https://zhuanlan.zhihu.com/p/549612117).

## Serical COM Port: UART

| Parameter | Value | 
| :-:       | :-:   | 
| Baud Rate | 9600  | 
| Parity Bit| Even  | 
| Stop Bit  |   1   |
| Data Length|  8   |

## FPGA Evaluation Board
Xilinx VC707 | Virtex-7 XC7VX485TFFG1761-2

## Developing Progress
- [ ] Read-Write Collision PUF
    - [x] Same Port, Both posedge experiment: **FAILED** 
    - [ ] Dual Port, Read Write Seperated experiment: **IN PROGRESS**
- [ ] Dual-Port Write Collision PUF