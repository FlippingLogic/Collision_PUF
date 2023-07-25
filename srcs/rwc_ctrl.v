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
    output  reg [31:0]  rsp_pos     ,
    output  reg [31:0]  rsp_neg
    );

    /*****************************Parameter*********************************/
    //parameter   ADDR_LENGTH     =   10      ;
    //parameter   DATA_LENGTH     =   32      ;
    parameter   CHALLENGE_CLEAR =   32'd0   ;

    /*****************************Register*********************************/
    reg             r_wea_pos       ;
    reg             r_wea_neg       ;
    reg [31:0]      r_bram_data     ;
    reg [1:0]       r_next_state    ;
    reg [1:0]       r_exec_state    ;

    /*****************************Wire************************************/
    wire            w_bram_wea      ;
    wire [31:0]     w_douta         ;
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

    always @(*) begin
        case(r_next_state)
            IDLE: available = 1'b1;
            default: available = 1'b0;
        endcase
    end

    always @(*) begin
        case (r_exec_state)
            IDLE:   r_next_state = gen_enable ? WRITE : IDLE;
            WRITE:  r_next_state = WAIT;
            WAIT:   r_next_state = CLEAR;
            CLEAR:  r_next_state = IDLE;
            default: r_next_state = r_next_state;
        endcase
    end

    /*******************************FSM**********************************/
    parameter   IDLE    =   2'b00  ,
                WRITE   =   2'b01  ,
                WAIT    =   2'b10  ,
                CLEAR   =   2'b11  ;

    always @(posedge clk) begin
        case (r_exec_state)
            IDLE: begin
                r_wea_pos <= 1'b1;
                r_bram_data <= cha_data;
            end
            WRITE: begin
                r_wea_pos <= ~r_wea_pos;
                rsp_pos <= w_doutb;
            end
            WAIT: begin
                r_bram_data <= CHALLENGE_CLEAR;
            end
            CLEAR: begin
                r_wea_pos <= ~r_wea_pos;
                rsp_pos <= w_doutb;
            end
            default: ;
        endcase
    end

    always @(negedge clk)begin
        case(r_exec_state)
            IDLE: r_wea_neg <= 1'b1;
            WRITE: begin
                r_wea_neg <= ~r_wea_neg;
                rsp_neg <= w_doutb;
            end
            WAIT: rsp_neg <= w_doutb;
            CLEAR: begin
                r_wea_neg <= ~r_wea_neg;
                rsp_neg <= w_doutb;
            end
            default: ;
        endcase
    end

    /****************************Instanation*****************************/
    blk_mem_gen_0 bram (
    .clka(clk),             // input wire clka
    .wea(w_bram_wea),             // input wire [0 : 0] wea, always write
    .addra(cha_addr),       // input wire [9 : 0] addra
    .dina(r_bram_data),     // input wire [31 : 0] dina
    .douta(w_douta),          // output wire [31 : 0] douta, should NEVER use
    .clkb(clk),             // input wire clkb
    .web(1'b0),             // input wire [0 : 0] web, always read
    .addrb(cha_addr),       // input wire [9 : 0] addrb
    .dinb({32{1'b0}}),      // input wire [31 : 0] dinb, should NEVER use
    .doutb(w_doutb)         // output wire [31 : 0] doutb
    );

endmodule
