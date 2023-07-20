# Collision_PUF

Summer Research Project at **VLSI Design Institute**, Yuquan Campus, Zhejiang University.  

This is a FPGA Implementation of Collision based SRAM PUFs.  
Read Write Collision (RWC) PUF woulld base on the literature [A new read–write collision-based SRAM PUF implemented on Xilinx FPGAs](https://link.springer.com/article/10.1007/s13389-021-00281-8).

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
    - Output: **Undetermined** Single Port Clock
- Block RAM Generator
    - True Dual Port Mode (TDP)
    - Data Width: 32
    - Data Depth: 1024
    - Read & Write Delay: 1 cycle (No primitive register enabled)

## Developing Progress
- [ ] Read-Write Collision PUF
    - [x] Single Port
        - [x] posedge WRITE posedge READ: **FAILED**: 500MHZ All success 
        - [x] posedge WRITE negedge READ: **FAILED**: 500MHZ All success 
    - [ ] Dual Port, Read Write Seperated
        - [x] posedge WRITE posedge READ: **FAILED**: 200MHZ All success
        - [x] posedge WRITE negedge READ: **FAILED**: 200MHZ NONE success (250MHZ once succeed)  
        _Note: There can be a critical value, for some cells to success and others fail_
        - [ ] Increse Frequency: **IN PROGRESS**
- [ ] Dual-Port Write Collision PUF
