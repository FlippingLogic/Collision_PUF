`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/14 16:23:04
// Design Name: 
// Module Name: puf_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module puf_top(
    input   sys_clk_p   ,
    input   sys_clk_n   ,
    input   rst         ,
    input   switch_0    ,
    );

    /*****************************Parameter*********************************/
    parameter   CHALLENGE_DATA  =   32'hFFFF_FFFF;
    parameter   CHALLENGE_ADDR  =   10'd0;

    /*****************************Register*********************************/

    /*****************************Wire************************************/
    wire    w_clk           ;
    wire    w_rwc_rsp_write ;
    wire    w_rwc_rsp_clean ;
    wire    w_rwc_available ;

    /*************************Combinational Logic************************/

    /****************************Processing******************************/

    /*******************************FSM**********************************/

    /*******************************LSM************************************/

    /****************************Instanation*****************************/
    clk_wiz_0 clock
    (
        .clk_out1(w_clk), // 300MHZ is chosen, according to the literature
        .reset(rst), 
        .clk_in1_p(sys_clk_p),
        .clk_in1_n(sys_clk_n)
    );

    rwc_ctrl rwc_gen
    (
        .clk(w_clk),      
        .rst(rst),
        .gen_enable(switch_0),  
        .cha_data(CHALLENGE_DATA),
        .cha_addr(CHALLENGE_ADDR),
        .available(w_rwc_available),
        .rsp_write(w_rwc_rsp_write),
        .rsp_clean(w_rwc_rsp_clean)
    );

    ila_0 probe (
	.clk(w_clk),
	.probe0(w_rwc_rsp_write),
	.probe1(w_rwc_rsp_clean) 
    );

endmodule
