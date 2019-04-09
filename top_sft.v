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
module top_sft;

   wire       tb_sim_rst;        // simulation only reset
   wire       clk12m;		// 12 mhz clock
   wire [4:0] leds;
   wire [7:0] tb_rx_data;
   wire       tb_rx_data_rdy;
   wire [7:0] ut_tx_data;
   wire       ut_tx_data_rdy;
       
   latticehx1k latticehx1k(
			   .sd(),
			   .clk_in(clk12m),
			   .from_pc(),
			   .to_ir(),
			   .o_serial_data(),
			   .test1(),
			   .test2(),
			   .test3(),
			   .led(leds),

			   .tb_sim_rst(tb_sim_rst),
			   .tb_rx_data(tb_rx_data),
			   .tb_rx_data_rdy(tb_rx_data_rdy),
			   .ut_tx_data(ut_tx_data),
			   .ut_tx_data_rdy(ut_tx_data_rdy)
			   );
   

   tb_sft tb_sft (
	          .tb_sim_rst(tb_sim_rst),
		  .clk12m(clk12m),
		  .ut_tx_data(ut_tx_data),
		  .ut_tx_data_rdy(ut_tx_data_rdy),
		  .tb_rx_data(tb_rx_data),
		  .tb_rx_data_rdy(tb_rx_data_rdy),
		  .leds(leds)
		  );

 	     

endmodule // top_sft
