`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Zhejiang University VLSI Design Institute
// Engineer: Yu Siying
// 
// Create Date: 2023/07/12 18:22:43
// Design Name: read write collision generator controller
// Module Name: rwc_ctrl
// Project Name: Collision PUF
// Target Devices: virtex-7 xc7vx485tffg1761-2
// Tool Versions: vivado 2023.1
// Description: Read-Write Collision based PUF for FPGA, based on published article. Generator Module.
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rwc_ctrl(
    input               clk         ,
    input               double_clk  , 
    input               rst         ,
    input               gen_enable  ,
    input       [31:0]  cha_data    ,
    input       [9:0]   cha_addr    ,
    output  reg         available   ,
    output  reg [31:0]  rsp_pos     ,
    output  reg [31:0]  rsp_neg
    );

    /*****************************Parameter*********************************/
    //parameter   ADDR_LENGTH     =   10      ;
    //parameter   DATA_LENGTH     =   32      ;
    parameter   CHALLENGE_CLEAR =   32'd0   ;

    /*****************************Register*********************************/
    reg [31:0]      r_bram_data     ;
    reg [2:0]       r_next_state    ;
    reg [2:0]       r_exec_state    ;

    /*****************************Wire************************************/
    wire            w_bram_wea      ;
    wire [31:0]     w_douta         ;
    wire [31:0]     w_doutb         ;

    /*************************Combinational Logic************************/
    assign w_resetn     =   ~rst                    ;

    /****************************Processing******************************/
    always @(posedge clk) begin
        if(!w_resetn) begin
            r_exec_state <= IDLE;
        end else begin
            r_exec_state <= r_next_state;
        end
    end

    always @(*) begin
        case(r_next_state)
            IDLE: available = 1'b1;
            default: available = 1'b0;
        endcase
    end

    always @(negedge double_clk)begin
        rsp_neg <= w_douta;
    end

    /*******************************FSM**********************************/
    parameter   IDLE    =   3'b000  ,
                WRITE   =   3'b001  ,
                RSP_A   =   3'b010  ,
                CLEAR   =   3'b011  ,
                RSP_B   =   3'b100  ;

    always @(*) begin
        case (r_exec_state)
            IDLE:   r_next_state = gen_enable ? WRITE : IDLE;
            WRITE:  r_next_state = RSP_A;
            RSP_A:  r_next_state = CLEAR;
            CLEAR:  r_next_state = RSP_B;
            RSP_B:  r_next_state = IDLE;
            default: r_next_state = r_next_state;
        endcase
    end

    always @(posedge clk) begin
        case (r_exec_state)
            IDLE:   r_bram_data <= gen_enable ? cha_data : CHALLENGE_CLEAR;
            RSP_A:  r_bram_data <= CHALLENGE_CLEAR;
            default: ;
        endcase
    end

    /****************************Instanation*****************************/
    blk_mem_gen_0 bram (
    .clka(clk),             // input wire clka
    .wea(1'b1),             // input wire [0 : 0] wea, always write
    .addra(cha_addr),       // input wire [9 : 0] addra
    .dina(r_bram_data),     // input wire [31 : 0] dina
    .douta(w_douta),        // output wire [31 : 0] douta, should NEVER use
    .clkb(clk),             // input wire clkb
    .web(1'b0),             // input wire [0 : 0] web, always read
    .addrb(cha_addr),       // input wire [9 : 0] addrb
    .dinb({32{1'b0}}),      // input wire [31 : 0] dinb, should NEVER use
    .doutb(w_doutb)         // output wire [31 : 0] doutb
    );

endmodule
