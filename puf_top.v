`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Zhejiang University
// Engineer: Yu Siying
// 
// Create Date: 2023/07/14 16:23:04
// Design Name: 
// Module Name: puf_top
// Project Name: 
// Target Devices: Xilinx VC707
// Tool Versions: Vivado 2023.1
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
    input           sys_clk_p   ,
    input           sys_clk_n   ,
    input           rst         ,
    input           enable      ,
    input   [7:0]   switch      ,
    output  [7:0]   led               
    );

    /*****************************Parameter*********************************/
    parameter   CHALLENGE_DATA  =   32'h2c77_d388;
    parameter   CHALLENGE_ADDR  =   10'd0;
    parameter   CLOCK_FREQUENCY =   300_000_000;

    /*****************************Register*********************************/
    reg             r_rwc_enable    ;
    reg [1:0]       r_exec_state    ;
    reg [1:0]       r_next_state    ;
    reg [27:0]      r_clk_cnt       ;
    reg [31:0]      r_rwc_data      ;
    reg [31:0]      r_rwc_addr      ;
    (* Mark_debug = "TRUE" *)   reg [31:0]  r_rwc_rsp_write ;
    (* Mark_debug = "TRUE" *)   reg [31:0]  r_rwc_rsp_clean ;

    /*****************************Wire************************************/
    wire            w_clk           ;
    wire            w_rwc_available ;
    wire [31:0]     w_rwc_rsp_write ;
    wire [31:0]     w_rwc_rsp_clean ;

    /*************************Combinational Logic************************/
    assign  w_resetn    =   ~rst            ;
    assign  led[1:0]    =   r_exec_state    ;

    /****************************Processing******************************/
    always @(posedge w_clk) begin
        if(!w_resetn) begin
            r_exec_state <= IDLE;
        end else begin
            r_exec_state <= r_next_state;
        end
    end

    /*******************************FSM**********************************/
    parameter IDLE      =   2'b00   ,
              CREATE    =   2'b01   ,
              DETECT    =   2'b10   ,
              WAIT      =   2'b11   ;

    always @(posedge w_clk) begin
        case(r_exec_state)
            IDLE: begin
                r_rwc_data <= CHALLENGE_DATA;
                r_rwc_addr <= CHALLENGE_ADDR;
                r_clk_cnt <= 'd0;
            end
            CREATE: begin
                r_rwc_enable <= 1'b1;
            end
            DETECT: begin
                r_rwc_enable <= 1'b0;
                r_rwc_rsp_write <= w_rwc_rsp_write;
                r_rwc_rsp_clean <= w_rwc_rsp_clean;
            end
            WAIT:begin
                r_clk_cnt <= r_clk_cnt + 1;
            end
            default: ;
        endcase
    end

    always @(posedge w_clk) begin
        case(r_exec_state)
            IDLE:   r_next_state = enable ? CREATE : IDLE;
            CREATE: r_next_state = w_rwc_available ? DETECT : CREATE;
            DETECT: r_next_state = WAIT;
            WAIT:   r_next_state = (r_clk_cnt == CLOCK_FREQUENCY/2-1) ? IDLE : WAIT;
            default: r_next_state <= r_next_state;
        endcase
    end

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
        .gen_enable(r_rwc_enable),  
        .cha_data(r_rwc_data),
        .cha_addr(r_rwc_addr),
        .available(w_rwc_available),
        .rsp_write(w_rwc_rsp_write),
        .rsp_clean(w_rwc_rsp_clean)
    );

    ila_0 probe (
	.clk(w_clk),
	.probe0(w_rwc_rsp_write),
	.probe1(w_rwc_rsp_clean),
    .probe2(r_exec_state)
    );

endmodule