# Collision_PUF

Summer Research Project at **VLSI Design Institute**, Yuquan Campus, Zhejiang University.  
Instructor: [Prof. Huang Kejie @ZJU](https://person.zju.edu.cn/huangkejie/702147.html)  
Special thanks to my seniors Wang Chengxuan & Yang Zhiyao.

This is a FPGA Implementation of Collision based SRAM PUFs. Read Write Collision (RWC) PUF would base on the literature [A new read–write collision-based SRAM PUF implemented on Xilinx FPGAs](https://link.springer.com/article/10.1007/s13389-021-00281-8).

UART implementation based on [(verilog)UART协议详讲与实现](https://zhuanlan.zhihu.com/p/549612117). (NOT used yet, will replace ILA later)

## Hardware and Settings
### FPGA Evaluation Board
Xilinx VC707 | Virtex-7 XC7VX485TFFG1761-2
### Serical COM Port: UART
- Baud Rate: 9600  
- Parity Bit: Even
- Stop Bit: 1
- Data Length: 8
### IP Core Settings
- Clock
    - Input: **200MHZ** Differential Clock (System Clock)
    - Output: **350MHZ** Single Port Clock
- Block RAM Generator
    - True Dual Port Mode (TDP)
    - Data Width: 32
    - Data Depth: 1024
    - Read & Write Delay: 1 cycle (No primitive register enabled)

## Developing Progress
Latest Progress is recorded in [RTL Source Log](https://github.com/FlippingLogic/Collision_PUF/blob/main/srcs/README.md), which is the README file in srcs folder.
- [ ] Read-Write Collision PUF
    - [x] Single Port: **FAILED**
    - [x] Dual Port: In progress, **SUCCEED**
- [ ] Dual-Port Write Collision PUF
