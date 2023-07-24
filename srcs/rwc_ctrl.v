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
    input               rst         ,
    input               gen_enable  ,
    input       [31:0]  cha_data    ,
    input       [9:0]   cha_addr    ,
    output  reg         available   ,
    output  reg [31:0]  rsp_write   ,
    output  reg [31:0]  rsp_clean
    );

    /*****************************Parameter*********************************/
    //parameter   ADDR_LENGTH     =   10      ;
    //parameter   DATA_LENGTH     =   32      ;
    parameter   CHALLENGE_CLEAR =   32'd0   ;

    /*****************************Register*********************************/
    reg             r_wea_pos       ;
    reg             r_wea_neg       ;
    reg [31:0]      r_bram_data     ;
    reg [2:0]       r_next_state    ;
    (* Mark_debug = "TRUE" *) reg [2:0]       r_exec_state    ;
    (* Mark_debug = "TRUE" *) reg [31:0]      r_rsp_full      ;

    /*****************************Wire************************************/
    wire            w_bram_wea      ;
    wire [31:0]     w_rsp           ;
    wire [31:0]     w_doutb         ;

    /*************************Combinational Logic************************/
    assign w_resetn     =   ~rst                    ;
    assign w_bram_wea   =   r_wea_pos ^ r_wea_neg   ;

    /****************************Processing******************************/
    always @(posedge clk) begin
        if(!w_resetn) begin
            r_exec_state <= IDLE;
        end else begin
            r_exec_state <= r_next_state;
        end
    end

    /*******************************FSM**********************************/
    parameter   IDLE    =   3'b000  ,
                WRITE   =   3'b001  ,
                RSP_A   =   3'b010  ,
                CLEAR   =   3'b011  ,
                RSP_B   =   3'b100  ;

    always @(posedge clk) begin
        case (r_exec_state)
            IDLE: begin
                r_bram_data <= cha_data;
                available <= 1'b1;
                r_wea_pos <= 1'b1;
            end
            WRITE: begin
                r_wea_pos <= ~r_wea_pos;
                available = 1'b0;
            end
            RSP_A: begin
                r_bram_data <= CHALLENGE_CLEAR;
                r_rsp_full <= w_doutb;
            end
            CLEAR: r_wea_pos <= ~r_wea_pos;
            default: ;
        endcase
    end

    always @(negedge clk)begin
        case(r_exec_state)
            IDLE: r_wea_neg <= 1'b1;
            RSP_A: begin
                r_wea_neg = ~r_wea_neg;
                rsp_write = w_doutb;
            end
            RSP_B: begin
                r_wea_neg = ~r_wea_neg;
                rsp_clean = w_doutb;
            end
            default: ;
        endcase
    end

    always @(posedge clk) begin
        case (r_exec_state)
            IDLE:   r_next_state = gen_enable ? WRITE : IDLE;
            WRITE:  r_next_state = RSP_A;
            RSP_A:  r_next_state = CLEAR;
            CLEAR:  r_next_state = RSP_B;
            RSP_B:  r_next_state = IDLE;
            default: r_next_state = r_next_state;
        endcase
    end

    /****************************Instanation*****************************/
    blk_mem_gen_0 bram (
    .clka(clk),             // input wire clka
    .wea(w_bram_wea),       // input wire [0 : 0] wea
    .addra(cha_addr),       // input wire [9 : 0] addra
    .dina(r_bram_data),     // input wire [31 : 0] dina
    .douta(w_rsp),          // output wire [31 : 0] douta, should NEVER use
    // PORT B is reserved, only use PORT A
    .clkb(clk),             // input wire clkb
    .enb(1'b1),             // input wire enb
    .web(1'b0),             // input wire [0 : 0] web
    .addrb(cha_addr),       // input wire [9 : 0] addrb
    .dinb({32{1'b0}}),      // input wire [31 : 0] dinb, should NEVER use
    .doutb(w_doutb)         // output wire [31 : 0] doutb
    );

endmodule
