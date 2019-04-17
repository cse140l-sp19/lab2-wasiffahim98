// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//   It is synthesisable for Lattice iCEstick 40HX.  
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// -------------------------------------------------------------------- //           
//                     Lih-Feng Tsaur
//                     Bryan Chin
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------
//
// software testbench for simulation starter code
//
`define MAXMSG 256

// if CHECKER is defined, then run self checking code
// if CHECKER is not defined, display the LED patterns
// `define CHECKER

module tb_sft(
	      output reg   tb_sim_rst,
	      output reg   clk12m,
	      input [7:0]  ut_tx_data,
	      input 	   ut_tx_data_rdy,

	      output reg [7:0] tb_rx_data,
	      output reg   tb_rx_data_rdy,

	      input [4:0]  leds
	      );
   
   //
   // neg
   // 2's complement t
   //
   function [3:0] neg (input [3:0] t);
      neg = ~t + 1;
   endfunction

   //
   // convert ascii to binary
   //
   // Note: this function contains behavioural code
   // and cannot should not be use in a hardware
   // implementation.
   //
   function [4:0] ascii2bin (input [7:0] t);
      reg [7:0] 	   bin8;    // 8 bit binary
      reg [4:0] 	   result;
      
      begin
	 
	 if ((t >= 8'h30) && (t <= 8'h3f)) begin
	    bin8 = t - 8'h30;
	    ascii2bin = {1'b0, bin8[3:0]};
	 end
	 else
	 if ((t >= 8'h50) && (t <= 8'h5f)) begin
	    bin8 = t - 8'h50;
	    ascii2bin = {1'b1, bin8[3:0]};
	 end
	 else
	   begin
	      ascii2bin = 5'b0000;
	   end
      end
   endfunction // ascii2bin
   
   //
   // print the "LEDS" to the screen
   //
   task displayLattice(input [4:0] leds);
      begin
	 #1;
	 $display("    [%c]", leds[2] ? "*":".");
	 $display(" [%c][%c][%c] ", leds[1] ? "*":".", leds[4] ? "*" : ".", leds[3] ? "*" : ".");
	 $display("    [%c]", leds[0] ? "*":".");
//	 $display($time,,, ": %d  %d  %c  -> %d %d", a, b, op ? "-" : "+", leds[4], leds[3:0]);
	 $display;
      end	 
   endtask


   //
   // sendByte
   // send the byte byt to the DUT
   //
   task sendByte(input [7:0] byt);
     begin
		@(posedge clk12m);
		tb_rx_data_rdy <= 1;
		tb_rx_data     <= byt;
		@(posedge clk12m);
		tb_rx_data_rdy <= 0;
     end
   endtask


   //
   // waitN
   // wait N cycles
   //
   task waitN(input integer N);
      begin
	 repeat (N) begin
	    @(posedge clk12m);
	 end
      end
   endtask // waitN
   
   

   reg [7:0] svOp1;
   reg [7:0] svOp2;
   reg [7:0] svOp;

   //
   // doOper
   // this task takes 3inputs (op1, op2 and op)
   // it saves each operation in svOp1, svOp2 and svOp respectively.
   // Then it callse send Byte to simulate sending these bytes one at
   // a time to the DUT.
   //
   task doOper(input [7:0] op1, input [7:0] op2, input [7:0] op);
      begin
	 svOp1 = op1;
 	 svOp2 = op2;
	 svOp  = op;
	 sendByte(op1);
	 sendByte(op2);
	 sendByte(op);
      end
   endtask // doOper
   


   //
   // reset generation
   //
   initial begin
      tb_sim_rst <= 0;
      clk12m <= 0;
      tb_rx_data = 8'b0;
      tb_rx_data_rdy = 1'b0;
      #40
      tb_sim_rst <= 1;
      #40
      #40
      #40
      #40
      tb_sim_rst <= 0;
   end

   //
   // clock generation
   //
   always @(*) begin
      #40;
      clk12m <= ~clk12m;
   end

`ifndef CHECKER
   //
   // when leds change display them
   //
   always @(leds) begin
      displayLattice(leds);
   end
`endif
   
   // ------------------------
   //
   // stimulus
   //
   // each call to doOper generates one
   // set of test stimulus
   //
   initial begin
      #400;
      #400;
      @(posedge clk12m);
      tb_rx_data = 8'b0;
      tb_rx_data_rdy = 1'b0;


      doOper("0", "4", "+");
      waitN(4);
      doOper("5", "2", "-");
      waitN(4);
      doOper("2", "3", "-");
      waitN(4);

      $finish;

   end

   //
   // tests
   //
   reg [4:0]	   tres;   // {cout, sum}
   reg [`MAXMSG * 8-1:0] tStr;
   
   reg [3:0] 		 op1bin;
   reg [3:0] 		 op2bin;


   //
   //
   // define CHECKER to turn on checking
   //
`ifdef CHECKER   
   always @(posedge ut_tx_data_rdy) begin
      #1;

      //
      // wait for 2 ready pulses from the DUT
      // these are echoing the user input to the terminal
      //
      @(posedge ut_tx_data_rdy);
      @(posedge ut_tx_data_rdy);
      
      //
      // now check to see what operation we sent
      // if its "+" then add svOp1 and svOp2.
      // if its "-" then subtracrt svOp2 from svOp1
      //
      // check to see if the DUT has sent us the correct answer.
      //
      if (svOp == "+") begin
	 op1bin = ascii2bin(svOp1);
	 op2bin = ascii2bin(svOp2);
	 tres = op1bin + op2bin;
	 if ( tres == ascii2bin(ut_tx_data)) begin
	    $display("pass : %s + %s = 0x%x != %s", svOp1, svOp2, tres, ut_tx_data);
	 end else
	    $display("fail : %s + %s 0x%x  == %s", svOp1, svOp2, tres, ut_tx_data);

	 if (tres == leds) begin
	    $display("pass : %s + %s = 0x%x != leds %b", svOp1, svOp2, tres, leds);
	 end else
	    $display("fail : %s + %s 0x%x  == leds %b", svOp1, svOp2, tres, leds);
      end
      else begin
	 op1bin = ascii2bin(svOp1);
	 op2bin = ascii2bin(svOp2);
	 tres = op1bin - op2bin;
	 if ( tres == ascii2bin(ut_tx_data)) begin
	    $display("pass : %s - %s 0x%x != %s", svOp1, svOp2, tres, ut_tx_data);
	 end else
	    $display("fail : %s - %s 0x%x == %s", svOp1, svOp2, tres, ut_tx_data);

	 if (tres == leds) begin
	    $display("pass : %s - %s = 0x%x != leds %b", svOp1, svOp2, tres, leds);
	 end else
	    $display("fail : %s - %s 0x%x  == leds %b", svOp1, svOp2, tres, leds);
      end // else: !if(svOp == "+")
   end	 
`endif
endmodule // tb_sft
