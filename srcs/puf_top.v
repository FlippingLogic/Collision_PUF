`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Zhejiang University VLSI Design Institute
// Engineer: Yu Siying
// 
// Create Date: 2023/07/14 16:23:04
// Design Name: read write collision generator controller
// Module Name: puf_top
// Project Name: Collision PUF
// Target Devices: virtex-7 xc7vx485tffg1761-2
// Tool Versions: vivado 2023.1
// Description: Read-Write Collision based PUF for FPGA, based on published article. TOP control Module.
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module puf_top(
    input           sys_clk_p   ,
    input           sys_clk_n   ,
    input           rst         ,
    input           enable      ,
    input   [7:0]   switch      ,
    output  [7:0]   led               
    );

    /*****************************Parameter*********************************/
    parameter   CHALLENGE_DATA  =   32'hFFFF_FFFF;
    parameter   CHALLENGE_ADDR  =   10'd0;
    parameter   CLOCK_FREQUENCY =   300_000_000;

    /*****************************Register*********************************/
    reg             r_rwc_enable    ;
    reg [2:0]       r_next_state    ;
    reg [27:0]      r_clk_cnt       ;
    reg [31:0]      r_rwc_data      ;
    reg [9:0]       r_rwc_addr      ;
    reg [2:0]       r_top_state     ;
    reg [31:0]      r_rwc_rsp_pos   ;
    reg [31:0]      r_rwc_rsp_neg   ;

    /*****************************Wire************************************/
    wire            w_clk           ;
    wire            w_ila_clk       ;
    wire            w_rwc_available ;
    wire [31:0]     w_rwc_rsp_pos   ;
    wire [31:0]     w_rwc_rsp_neg   ;

    /*************************Combinational Logic************************/
    assign  w_resetn    =   ~rst            ;
    assign  led[1:0]    =   r_top_state     ;

    /****************************Processing******************************/
    always @(posedge w_clk) begin
        if(!w_resetn) begin
            r_top_state <= IDLE;
        end else begin
            r_top_state <= r_next_state;
        end
    end

    always @(*) begin
        case(r_top_state)
            IDLE:   r_next_state = enable ? ENABLE : IDLE;
            ENABLE: r_next_state = WAIT;
            WAIT:   r_next_state = CREATE;
            CREATE: r_next_state = w_rwc_available ? REST : CREATE;
            REST:   r_next_state = (r_clk_cnt == CLOCK_FREQUENCY/2-1) ? IDLE : REST;
            default: r_next_state = r_next_state;
        endcase
    end

    /*******************************FSM**********************************/
    parameter IDLE      =   3'b000  ,
              ENABLE    =   3'b001  ,
              WAIT      =   3'b010  ,
              CREATE    =   3'b011  ,
              REST      =   3'b100  ;

    always @(posedge w_clk) begin
        case(r_top_state)
            IDLE: begin
                r_rwc_data <= CHALLENGE_DATA;
                r_rwc_addr <= CHALLENGE_ADDR;
                r_clk_cnt <= 'd0;
                r_rwc_enable <= 1'b0;
            end
            ENABLE: r_rwc_enable <= 1'b1;
            CREATE: r_rwc_enable <= 1'b0;
            REST:   r_clk_cnt <= r_clk_cnt + 1;
            default: ;
        endcase
    end

    /****************************Instanation*****************************/
    clk_wiz_0 clock
    (
        .clk_out1(w_clk),
        .clk_out2(w_ila_clk),
        .reset(rst), 
        .clk_in1_p(sys_clk_p),
        .clk_in1_n(sys_clk_n)
    );

    rwc_ctrl rwc_gen
    (
        .clk(w_clk),      
        .rst(rst),
        .gen_enable(r_rwc_enable),  
        .cha_data(r_rwc_data),
        .cha_addr(r_rwc_addr),
        .available(w_rwc_available),
        .rsp_pos(w_rwc_rsp_pos),
        .rsp_neg(w_rwc_rsp_neg)
    );

    ila_0 probe (
        .clk(w_ila_clk),
        .probe0(r_top_state),
        .probe1(rwc_gen.r_exec_state),
        .probe2(rwc_gen.w_bram_wea),
        .probe3(rwc_gen.w_doutb)
    );

endmodule