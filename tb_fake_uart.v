module tb_fake_uart_rx(
		       input 	   i_clk,
		       input       i_rst, 	   
		       input [7:0] tb_rx_data,
		       input 	   tb_rx_data_rdy,
		       output reg  o_rx_data_ready,
		       output reg [7:0] o_rx_data
		       );


   always @(posedge i_clk or posedge i_rst) begin
      if (i_rst) begin
	 o_rx_data <= 8'b0;
	 o_rx_data_ready <= 1'b0;
      end
      else begin
	 o_rx_data <= tb_rx_data;
	 o_rx_data_ready <= tb_rx_data_rdy;
      end
   end
endmodule
      
module tb_fake_uart_tx(
		       input 	   i_clk,
		       input       i_rst, 	   
		       input [7:0] i_tx_data,
		       input 	   i_start_tx,
		       output reg [7:0] ut_tx_data,
		       output reg ut_tx_data_rdy
		       );

   always @(posedge i_clk or posedge i_rst) begin
      if (i_rst) begin
	 ut_tx_data <= 8'b0;
	 ut_tx_data_rdy <= 1'b0;
      end
      else begin
	 ut_tx_data <= i_tx_data;
	 ut_tx_data_rdy <= i_start_tx;
      end
   end

endmodule
      
