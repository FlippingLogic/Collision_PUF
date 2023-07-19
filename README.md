# read_write_collision_PUF

Summer research project at **VLSI Design Institute**, Yuquan Campus, Zhejiang University.  

This is a FPGA Implementation of read write collision (RWC) based SRAM PUF, based on the literature by Ihsan Cicek and Ahmad Al Khas:
[A new read–write collision-based SRAM PUF implemented on Xilinx FPGAs](https://link.springer.com/article/10.1007/s13389-021-00281-8).

UART implementation based on [(verilog)UART协议详讲与实现](https://zhuanlan.zhihu.com/p/549612117).
    
***

FPGA Evaluation Board
- Xilinx VC707
    - Virtex-7 xc7vx485tffg1761-2
    - Under development
- PangoMicro Titan2
    - PG2T390H-6 | FFBG9000
    - Develop Pending

***

Serical Port: UART

| Parameter | Value | 
| :-:       | :-:   | 
| Baud Rate | 9600  | 
| Parity Bit| Even  | 
| Stop Bit  |   1   |
| Data Length|  8   |

