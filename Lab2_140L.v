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
module Lab2_140L (
 input wire Gl_rst,                  // reset signal (active high)
 input wire clk,                     // global clock
 input wire Gl_adder_start,          // r1, r2, OP are ready  
 input wire Gl_subtract,             // subtract (active high)
 input wire [7:0] Gl_r1           , // 8bit number 1
 input wire [7:0] Gl_r2           , // 8bit number 1
 output wire [7:0] L2_adder_data   ,   // 8 bit ascii sum
 output wire L2_adder_rdy          , //pulse
 output wire [7:0] L2_led
);
addition add1(Gl_r1, Gl_r2, L2_rdy, Gl_subtract, carryOut, L2_adder_data);
//subtract(Gl_r1, Gl_r2, L2_rdy, L2_adder_data);
sigDelay delay1(L2_adder_rdy, Gl_adder_start, clk, Gl_rst);
assign L2_led = {carryOut, L2_adder_data};

endmodule

module sigDelay(
		  output      sigOut,
		  input       sigIn,
		  input       clk,
		  input       rst);

   parameter delayVal = 4;
   reg [15:0] 		      delayReg;


   always @(posedge clk) begin
      if (rst)
	delayReg <= 16'b0;
      else begin
	 delayReg <= {delayReg[14:0], sigIn};
      end
   end

   assign sigOut = delayReg[delayVal];
endmodule // sigDelay

module addition(input[7:0] Gl_r1, input[7:0] Gl_r2, input Gl_subtract, output cout, output carryOut, output L2_adder_data);
	reg [3:0] a;
	reg [3:0] b;
	reg [3:0] c;
	
	wire [3:0] sum;
	
	always @(*) begin
		a[0] = Gl_r1[0];
		a[1] = Gl_r1[1];
		a[2] = Gl_r1[2];
		a[3] = Gl_r1[3];
	end
/*	
	always @(*) begin
		b[0] = Gl_r2[0];
		b[1] = Gl_r2[1];
		b[2] = Gl_r2[2];
		b[3] = Gl_r2[3];
	end
*/	
/*
	always @(*) begin
	if(Gl_subtract == 1)
		c[3] = ~b[3];
		c[2] = ~b[2];
		c[1:0] = (~b[1:0] + 'b1);
	end
*/
	always @(*) begin
	if(Gl_subtract == 0) begin
		b[0] = Gl_r2[0];
		b[1] = Gl_r2[1];
		b[2] = Gl_r2[2];
		b[3] = Gl_r2[3];
	end
	else
	begin
		b[3] = ~Gl_r2[3];
		b[2] = ~Gl_r2[2];
		b[1:0] = (~Gl_r2[1:0] + 'b1);
	end
	end
	wire cin;
	assign cin = 1'b0;
	wire bit0,bit1,bit2;
	//wire [3:0] c;
	//assign c[0] = b[0] ^ carryOut;
	//assign c[1] = b[1] ^ carryOut;
	//assign c[2] = b[2] ^ carryOut;
	//assign c[3] = b[3] ^ carryOut;
	
	
	singleBit sum0(.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(bit0));
	singleBit sum1(.a(a[1]), .b(b[1]), .cin(bit0), .sum(sum[1]), .cout(bit1));
	singleBit sum2(.a(a[2]), .b(b[2]), .cin(bit1), .sum(sum[2]), .cout(bit2));
	singleBit sum3(.a(a[3]), .b(b[3]), .cin(bit2), .sum(sum[3]), .cout(carryOut));
	
	
	
	/*always @(*) begin
		//if(Gl_subtract == 1'b0) 
		//begin
			singleBit sum0(.a[0](a[0]), .b[0](b[0]), .cin(cin), .sum[0](sum[0]), .cout(bit0));
			singleBit sum1(.a(a[1]), .b(b[1]), .cin(bit0), .sum(sum[1]), .cout(bit1));
			singleBit sum2(.a(a[2]), .b(b[2]), .cin(bit1), .sum(sum[2]), .cout(bit2));
			singleBit sum3(.a(a[3]), .b(b[3]), .cin(bit2), .sum(sum[3]), .cout(carryOut));*/
		//end
/*	else
		begin
		wire [3:0] c;
		c[3] = b[3];
		c[2] = b[2];
		c[1:0] = (~b[1:0] + 'b1);
		
		singleBit diff0(.a(a[0]), .c(c[0]), .cin(cin), .sum(sum[0]), .cout(bit0));
		singleBit diff1(.a(a[1]), .c(c[1]), .cin(bit0), .sum(sum[1]), .cout(bit1));
		singleBit diff2(.a(a[2]), .c(c[2]), .cin(bit1), .sum(sum[2]), .cout(bit2));
		singleBit diff3(.a(a[3]), .c(c[3]), .cin(bit2), .sum(sum[3]), .cout(carryOut));
		end  */
	
	reg [7:0] d;
	always @(*)
	begin
	if(Gl_subtract == 0) begin
		if(carryOut == 0) begin
			d = {4'b0011,sum};
		 end
		else
		begin
			d = {4'b0101,sum};
		end
	end
	else
	begin
		if(carryOut == 1) begin
			d = {4'b0011,sum};
		 end
		else
		begin
			d = {4'b0101,sum};
		end
	end
	end 
	assign L2_adder_data = d;
endmodule 
/*
module subtract(input G1_r1, input Gl_r2, output cout, output sum);
	reg [3:0] a = Gl_r1;
	reg [3:0] b = Gl_r2;
	wire cin;
	assign cin = 1'b1;
	singleBit sum0(.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(bit0));
	singleBit sum1(.a(a[1]), .b(b[1]), .cin(bit0), .sum(sum[1]), .cout(bit1));
	singleBit sum2(.a(a[2]), .b(b[2]), .cin(bit1), .sum(sum[2]), .cout(bit2));
	singleBit sum3(.a(a[3]), .b(b[3]), .cin(bit2), .sum(sum[3]), .cout(bit3));
endmodule
*/
module singleBit(input a, input b, input cin, output sum, output cout);
	assign sum = a ^ b ^ cin;
	assign cout = (a & b)|(a & cin)|(b & cin);
endmodule 