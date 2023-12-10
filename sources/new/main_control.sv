`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// // Engineer: Oguz Kaan Agac & Bora Ecer
// 
// Create Date: 14/12/2016
// Design Name: Controller
// Module Name: main_control
// Project Name: BASPONG
// Target Devices: BASYS3
// Description: 
// Controller for the BASPONG
// Dependencies: 
// clk_wiz
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main_control(
    input logic clk,
    input logic start,   
    input logic reset,
    input logic bottom_button_l,
    input logic bottom_button_r,
    input logic top_button_l,
    input logic top_button_r,
    input logic start_ball,
    output logic[2:0] rgb, 
    output logic horizontal_sync,
    output logic vertical_sync,
    output a, b, c, d, e, f, g, dp,
    output [3:0] an,
    output wire RsTx, //uart
    input wire RsRx //uart
     ); 

reg score_checker1;
reg score_checker2;
reg [3:0] player1_score_0;
reg [3:0] player1_score_1;
reg [3:0] player2_score_0;
reg [3:0] player2_score_1;

initial 
                        begin : process_0
                        player1_score_0 = 'b0000;
                        player1_score_1 = 'b0000;
                        player2_score_0 = 'b0000;
                        player2_score_1 = 'b0000;
                        score_checker1 = 0;
                        score_checker2 = 0;
                        end

//signal x,y:std_logic_vector(9 downto 0);
reg[9:0] x_control;
reg[9:0] y_control;

//signal video:std_logic;
reg video_on;

//signal clk_50 :std_logic;
reg clk_50;

reg [7:0] data_in;
wire [7:0] data_out;
reg bbl, bbr, tbl, tbr;

//Vivado CLK wizzard to create 50MHz clock 
clk_wiz_0(clk_50, reset, clk);

uart(clk, data_in, data_out, RsRx, RsTx);

//Module to create animations
anim_gen(clk_50, reset, x_control,start_ball, bbl || bottom_button_l, bbr || bottom_button_r, tbl || top_button_l, tbr || top_button_r, y_control, video_on, rgb, score_checker1, score_checker2);

//vga synchronization module to update changing pixels and refresh the display
sync_mod(clk_50, reset, start, y_control, x_control, horizontal_sync, vertical_sync, video_on);

always_ff @(posedge clk)
begin
    if (data_in === 8'h74) begin
        bbl <= 0;
        bbr <= 0;
    end else if (data_in === 8'h62) begin
        bbl <= 1;
        bbr <= 0;
    end else if (data_in == 8'h65) begin
        bbl <= 0;
        bbr <= 1;
    end else if (data_in == 8'h6c) begin
        tbl <= 0;
        tbr <= 0;
    end else if (data_in == 8'h6b) begin
        tbl <= 1;
        tbr <= 0;
    end else if (data_in == 8'h6d) begin
        tbl <= 0;
        tbr <= 1;
    end
end

//if score checker1 is enabled that means player 1(topbar) scored, so update  his score
always_ff @(posedge clk_50, posedge reset)
begin
    if (reset == 1) begin
        player1_score_0 <= 0;
        player1_score_1 <= 0;
    end else if (score_checker1 == 1) begin
        if (player1_score_0 == 9) begin
            player1_score_0 <= 0;
            player1_score_1 <= player1_score_1 + 1;
        end else begin
            player1_score_0 <= player1_score_0 + 1;
        end
    end
end

//if score checker2 is enabled that means player2 (bottom bar) scored, so update his score
always_ff @(posedge clk_50, posedge reset)
begin
    if (reset == 1) begin
        player2_score_0 <= 0;
        player2_score_1 <= 0;
    end else if (score_checker2 == 1) begin
        if (player2_score_0 == 9) begin
            player2_score_0 <= 0;
            player2_score_1 <= player2_score_1 + 1;
        end else begin
            player2_score_0 <= player2_score_0 + 1;
        end
    end
end

//Module to display the scores on the 7seg display of basys3
SevenSegment(clk_50, player1_score_0, player1_score_1, player2_score_0, player2_score_1, a, b, c, d, e, f, g, dp,an);
// SevenSegment(clk_50, data_in[3:0], data_in[7:4], data_out[3:0], data_out[7:4], a, b, c, d, e, f, g, dp,an);

endmodule