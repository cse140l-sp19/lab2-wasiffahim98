//
// software testbench for simulation
//
`define MAXMSG 256

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
	 else if ((t>= 8'h61) && (t <= 8'h66)) begin
	    // a-f
	    bin8 = t - 8'h61;
	    ascii2bin = {1'b0, bin8[3:0] + 4'ha};
	 end
	 else if ((t>= 8'h41) && (t <= 8'h46)) begin
	    // A-F
	    bin8 = t - 8'h41;
	    ascii2bin = {1'b1, bin8[3:0] + 4'ha};
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

   task sendByte(input [7:0] byt);
     begin
		@(posedge clk12m);
		tb_rx_data_rdy <= 1;
		tb_rx_data     <= byt;
		@(posedge clk12m);
		tb_rx_data_rdy <= 0;
     end
   endtask

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
   // print out a snipped of JSON for one test
   //
   task jsonTest(input integer firstOne, input integer tNum, input reg[`MAXMSG * 8-1:0] oStr, input integer score);
      begin
	 $display("%c { \"name\" : \"test%d\",", (firstOne == 1'b1) ? " ": ",", tNum);
	 $display("%-s", oStr);
	 $display("\"score\" : %d}", score);
      end
   endtask


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

   always @(*) begin
      #40;
      clk12m <= ~clk12m;
   end

//   always @(leds) begin
//      displayLattice(leds);
//   end

   always @(posedge ut_tx_data_rdy) begin
	   #1;
	   $display("%s", ut_tx_data);
   end

 
   
   // ------------------------
   //
   // stimulus
   //
   //
   initial begin
      #400;
      #400;
      @(posedge clk12m);
      $display("{\"vtests\" : [");
      tb_rx_data = 8'b0;
      tb_rx_data_rdy = 1'b0;
      //
      doOper("0", "4", "+");
      waitN(4);
      doOper("5", "2", "-");
      waitN(4);
      doOper("2", "3", "-");
      waitN(4);
      doOper("2", "3", "-");
      waitN(4);
      doOper("2", "3", "-");
      waitN(4);
      doOper("2", "3", "-");
      waitN(4);
      doOper("2", "3", "-");
      waitN(4);
      doOper("2", "3", "-");
      waitN(4);
      //
      $display("]}");
      $finish;

   end

   integer testCount = 0;
   integer errorCount = 0;
   integer score = 1;
   integer firstOne = 1;
   //
   // tests
   //
   reg [4:0]	   tres;   // {cout, sum}
   reg [`MAXMSG * 8-1:0] tStr;
   
   reg [3:0] 		 op1bin;
   reg [3:0] 		 op2bin;
   
   always @(posedge ut_tx_data_rdy) begin
      #1;
      testCount = testCount + 1;
      score = 1;

      @(posedge ut_tx_data_rdy);
      @(posedge ut_tx_data_rdy);
      
      if (svOp == "+") begin
	 firstOne = 1;
	 op1bin = ascii2bin(svOp1);
	 op2bin = ascii2bin(svOp2);
	 tres = op1bin + op2bin;
	 if ( tres != ascii2bin(ut_tx_data)) begin
	    $sformat(tStr, "\"output\" : \"fail : %s + %s = 0x%x != %s\",", svOp1, svOp2, tres, ut_tx_data);
	    errorCount = errorCount + 1;
	    score = 0;
	 end else
	    $sformat(tStr, "\"output\" : \"pass : %s + %s 0x%x  == %s\",", svOp1, svOp2, tres, ut_tx_data);
	 jsonTest(firstOne, testCount, tStr, score);

	 testCount = testCount + 1;
	 if (tres != leds) begin
	    $sformat(tStr, "\"output\" : \"fail : %s + %s = 0x%x != leds %b \",", svOp1, svOp2, tres, leds);
	    errorCount = errorCount + 1;
	    score = 0;
	 end else
	    $sformat(tStr, "\"output\" : \"pass : %s + %s 0x%x  == leds %b\",", svOp1, svOp2, tres, leds);
	 jsonTest(firstOne, testCount, tStr, score);
      end
      else begin
	 firstOne = 1;
	 op1bin = ascii2bin(svOp1);
	 op2bin = ascii2bin(svOp2);
	 tres = op1bin - op2bin;
	 if ( tres != ascii2bin(ut_tx_data)) begin
	    $sformat(tStr, "\"output\" : \"fail : %s - %s 0x%x != %s\",", svOp1, svOp2, tres, ut_tx_data);
	    errorCount = errorCount + 1;
	    score = 0;
	 end else
	    $sformat(tStr, "\"output\" : \"pass : %s - %s 0x%x == %s\",", svOp1, svOp2, tres, ut_tx_data);
	 jsonTest(firstOne, testCount, tStr, score);

	 testCount = testCount + 1;
	 if (tres != leds) begin
	    $sformat(tStr, "\"output\" : \"fail : %s - %s = 0x%x != leds %b \",", svOp1, svOp2, tres, leds);
	    errorCount = errorCount + 1;
	    score = 0;
	 end else
	    $sformat(tStr, "\"output\" : \"pass : %s - %s 0x%x  == leds %b\",", svOp1, svOp2, tres, leds);
	 jsonTest(firstOne, testCount, tStr, score);
      end // else: !if(svOp == "+")
   end	 

endmodule // tb_sft
