`timescale 1 ns / 1 ns // timescale for following modules

//////////////////////////////////////////////////////////////////////////////////
// // Engineer: Oguz Kaan Agac & Bora Ecer
// 
// Create Date: 13/12/2016
// Design Name: Animation Logic
// Module Name: anim_gen
// Project Name: BASPONG
// Target Devices: BASYS3
// Description: 
// Controller for the BASPONG
// Dependencies: 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module anim_gen (
   clk,
   reset,
   x_control,
   stop_ball,
   bottom_button_l,
   bottom_button_r,
   top_button_l,
   top_button_r,
   y_control,
   video_on,
   rgb,
   score1,
   score2);
 

input clk; 
input reset; 
input[9:0] x_control; 
input stop_ball; 
input bottom_button_l; 
input bottom_button_r; 
input top_button_l; 
input top_button_r; 
input[9:0] y_control; 
input video_on; 
output[2:0] rgb; 
output score1; 
output score2; 

reg[2:0] rgb; 
reg score1; 
reg score2; 
reg scoreChecker1; 
reg scoreChecker2; 
reg scorer; 
reg scorerNext; 

// rightbar
integer rightbar_t; // the distance between bar and top side of screen
integer rightbar_t_next; // the distance between bar and top side of screen
parameter rightbar_l = 620; // the distance between bar and left side of screen
parameter rightbar_thickness = 10; // thickness of the bar
parameter rightbar_h = 120; // height of the right bar
parameter rightbar_v = 10; //velocity of the bar
wire display_rightbar; //to send right bar to vga

// leftbar
integer leftbar_t; // the distance between bar and top side of screen
integer leftbar_t_next; // the distance between bar and top side of screen
parameter leftbar_l = 20; // the distance between bar and left side of screen
parameter leftbar_thickness = 10; // thickness of the bar
parameter leftbar_h = 120; // height of the left bar
parameter leftbar_v = 10; //velocity of the bar
wire display_leftbar; //to send left bar to vga
wire[2:0] rgb_leftbar; //color

// ball
integer ball_c_l; // the distance between the ball and left side of the screen
integer ball_c_l_next; // the distance between the ball and left side of the screen 
integer ball_c_t; // the distance between the ball and top side of the screen
integer ball_c_t_next; // the distance between the ball and top side of the screen
parameter ball_default_c_t = 200; // default value of the distance between the ball and top side of the screen
parameter ball_default_c_l = 300; // default value of the distance between the ball and left side of the screen
parameter ball_r = 8; //radius of the ball.
parameter horizontal_velocity = 3; // Horizontal velocity of the ball  
parameter vertical_velocity = 3; //Vertical velocity of the ball
wire display_ball; //to send ball to vga 
wire[2:0] rgb_ball;//color 

// refresh
integer refresh_reg; 
integer refresh_next; 
parameter refresh_constant = 830000;  
wire refresh_rate; 

// ball animation
integer horizontal_velocity_reg; 
integer horizontal_velocity_next; 
integer vertical_velocity_reg; 

// x,y pixel cursor
integer vertical_velocity_next; 
wire[9:0] x; 
wire[8:0] y; 

// mux to display
wire[3:0] output_mux; 

// buffer
reg[2:0] rgb_reg; 

// x,y pixel cursor
wire[2:0] rgb_next; 

initial
   begin
   vertical_velocity_next = 0;
   vertical_velocity_reg = 0;
   horizontal_velocity_next = 0;
   horizontal_velocity_reg = 0;
   ball_c_t_next = 200;
   ball_c_t = 200;
   ball_c_l_next = 300;  
   ball_c_l = 300; 
   leftbar_t_next = 175;
   leftbar_t = 175;
   rightbar_t_next = 175;
   rightbar_t = 175;
   end
assign x = x_control; 
assign y = y_control; 

// refreshing

always @(posedge clk)
   begin //: process_1
   refresh_reg <= refresh_next;   
   end

//assigning refresh logics.
assign refresh_next = refresh_reg === refresh_constant ? 0 : 
	refresh_reg + 1; 
assign refresh_rate = refresh_reg === 0 ? 1'b 1 : 
	1'b 0; 

// register part
always @(posedge clk or posedge reset)
   begin 
   if (reset === 1'b 1) // to reset the game.
      begin
      ball_c_l <= ball_default_c_l;   
      ball_c_t <= ball_default_c_t;
      leftbar_t <= 260;
      rightbar_t <= 260;   
      horizontal_velocity_reg <= 0;   
      vertical_velocity_reg <= 0;   
      end
   else 
      begin
      horizontal_velocity_reg <= horizontal_velocity_next; //assigns horizontal velocity
      vertical_velocity_reg <= vertical_velocity_next; // assigns vertical velocity
      if (stop_ball === 1'b 1) // throw the ball
         begin
         if (scorer === 1'b 0) // if scorer is not the 1st player throw the ball to 1st player (2nd player scored) .
            begin
            horizontal_velocity_reg <= 3;   
            vertical_velocity_reg <= 1;   
            end
         else // first player scored. Throw the ball to the 2nd player.
            begin
            horizontal_velocity_reg <= -3;   
            vertical_velocity_reg <= -1;   
            end
         end
      ball_c_l <= ball_c_l_next; //assigns the next value of the ball's location from the left side of the screen to it's location.
      ball_c_t <= ball_c_t_next; //assigns the next value of the ball's location from the top side of the screen to it's location.  
      leftbar_t <= leftbar_t_next;   //assigns the next value of the left bars's location from the top side of the screen to it's location.
      rightbar_t <= rightbar_t_next;   //assigns the next value of the right bars's location from the top side of the screen to it's location.
      scorer <= scorerNext;
      end
   end

// leftbar animation
always @(leftbar_t or refresh_rate or bottom_button_r or bottom_button_l)
   begin 
   leftbar_t_next <= leftbar_t;   //assign leftbar_t to it's next value
   if (refresh_rate === 1'b 1) //refresh_rate's posedge
      begin
      if (bottom_button_l === 1'b 1 & leftbar_t > leftbar_v) //left button is pressed and left bar can move to the left.
         begin                                                // in other words, bar is not on the left edge of the screen.
         leftbar_t_next <= leftbar_t - leftbar_v;   //move left bar to the left
         end
      else if (bottom_button_r === 1'b 1 & leftbar_t < 479 - leftbar_v - leftbar_h ) //right button is pressed and left bar can move to the right 
         begin                                                                        //in other words, bar is not on the right edge of the screen
         leftbar_t_next <= leftbar_t + leftbar_v;   // move left bar to the right
         end
      else
         begin
         leftbar_t_next <= leftbar_t;   
         end
      end
   end

// rightbar animation
always @(rightbar_t or refresh_rate or top_button_r or top_button_l)
   begin 
   rightbar_t_next <= rightbar_t;   //assign rightbar_t to it's next value
   if (refresh_rate === 1'b 1) //refresh_rate's posedge
      begin
      if (top_button_l === 1'b 1 & rightbar_t > rightbar_v) //left button is pressed and right bar can move to the left.
         begin                                               // in other words, bar is not on the left edge of the screen.
         rightbar_t_next <= rightbar_t - rightbar_v;   //move right bar to the left
         end
      else if (top_button_r === 1'b 1 & rightbar_t < 479 - rightbar_v - rightbar_h ) //right button is pressed and right bar can move to the right 
         begin                                                                         //in other words, bar is not on the right edge of the screen
         rightbar_t_next <= rightbar_t + rightbar_v;   // move right bar to the right
         end
      else
         begin
         rightbar_t_next <= rightbar_t;   
         end
      end
   end

// ball animation
always @(refresh_rate or ball_c_l or ball_c_t or horizontal_velocity_reg or vertical_velocity_reg)
   begin 
   ball_c_l_next <= ball_c_l;   
   ball_c_t_next <= ball_c_t;   
   scorerNext <= scorer;   
   horizontal_velocity_next <= horizontal_velocity_reg;   
   vertical_velocity_next <= vertical_velocity_reg;   
   scoreChecker1 <= 1'b 0; //1st player did not scored, default value
   scoreChecker2 <= 1'b 0; //2st player did not scored, default value  
   if (refresh_rate === 1'b 1) // posedge of refresh_rate
      begin
      // if balls hits the leftbar
      if (ball_c_l >= leftbar_l & ball_c_l <= leftbar_l + 10 & ball_c_t >= leftbar_t & ball_c_t <= leftbar_t + 120) 
         begin
         horizontal_velocity_next <= horizontal_velocity; // set the direction of horizontal velocity negative
         end
      else if (ball_c_l >= rightbar_l - 3 & ball_c_l <= rightbar_l + 5 & ball_c_t >= rightbar_t & ball_c_t <= rightbar_t + 120) // if ball hits the right bar
         begin
         horizontal_velocity_next <= -horizontal_velocity; // set the direction of horizontal velocity positive
         end
      // if the balls hit the top of the screen
      else if (ball_c_t < 0) // if the ball hits the top of the screen
         begin
         vertical_velocity_next <= vertical_velocity; // set the direction of vertical velocity negative
         end
      else if (ball_c_t > 477) // if the ball hits the bottom of the screen
         begin
         vertical_velocity_next <= -vertical_velocity; // set the direction of vertical velocity positive
         end
      ball_c_l_next <= ball_c_l + horizontal_velocity_reg; //move the ball's horizontal location   
      ball_c_t_next <= ball_c_t + vertical_velocity_reg; // move the ball's vertical location.

      // if player 1 score, in other words, ball passes through the horizontal location of right bar.
      if (ball_c_l === 630) 
         begin
         ball_c_l_next <= ball_default_c_l; //reset the ball's location to its default.   
         ball_c_t_next <= ball_default_c_t; //reset the ball's location to its default.  
         horizontal_velocity_next <= 0; //stop the ball  
         vertical_velocity_next <= 0; //stop the ball  
         scorerNext <= 1'b 1;   
         scoreChecker2 <= 1'b 1; //2nd player scored.  
         end
      else
         begin
         scoreChecker2 <= 1'b 0;   
         end
      // if player 2 score, in other words, ball passes through the horizontal location of left bar.
      if (ball_c_l === 0) 
         begin
         ball_c_l_next <= ball_default_c_l; //reset the ball's location to its default.   
         ball_c_t_next <= ball_default_c_t; //reset the ball's location to its default.  
         horizontal_velocity_next <= 0; //stop the ball  
         vertical_velocity_next <= 0; //stop the ball  
         scorerNext <= 1'b 0;   
         scoreChecker1 <= 1'b 1; //1st player scored.  
         end
      else
         begin
         scoreChecker1 <= 1'b 0;   
         end
      end
   end

// display rightbar object on the screen
assign display_rightbar = x > rightbar_l & x < rightbar_l + rightbar_thickness & y > rightbar_t & 
    y < rightbar_t + rightbar_h ? 1'b 1 : 
   1'b 0;
assign rgb_rightbar = 3'b 001; //color of right bar: green

// display leftbar object on the screen
assign display_leftbar = x > leftbar_l & x < leftbar_l + leftbar_thickness & y > leftbar_t & 
    y < leftbar_t + leftbar_h ? 1'b 1 : 
   1'b 0;
assign rgb_leftbar = 3'b 100; //color of left bar: green

// display ball object on the screen
assign display_ball = (x - ball_c_l) * (x - ball_c_l) + (y - ball_c_t) * (y - ball_c_t) <= ball_r * ball_r ? 
    1'b 1 : 
	1'b 0; 
assign rgb_ball = 3'b 111; //color of ball: white


always @(posedge clk)
   begin 
   rgb_reg <= rgb_next;   
   end

// mux
assign output_mux = {video_on, display_rightbar, display_leftbar, display_ball}; 

//assign rgb_next wrt output_mux.
assign rgb_next = output_mux === 4'b 1000 ? 3'b 000 : 
	output_mux === 4'b 1100 ? rgb_leftbar : 
	output_mux === 4'b 1101 ? rgb_leftbar : 
	output_mux === 4'b 1010 ? rgb_rightbar : 
	output_mux === 4'b 1011 ? rgb_rightbar : 
	output_mux === 4'b 1001 ? rgb_ball : 
	3'b 000; 
	

// output part
assign rgb = rgb_reg; 
assign score1 = scoreChecker1; 
assign score2 = scoreChecker2; 

endmodule // end of module anim_gen