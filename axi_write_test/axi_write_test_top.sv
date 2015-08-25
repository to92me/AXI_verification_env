`ifndef AXI_WRITE_TEST_TOP_SVH
`define AXI_WRITE_TEST_TOP_SVH


`include "sv/axi_if.sv"
`include "sv/axi_pkg.sv"

import uvm_pkg::*;
`include "uvm_macros.svh"

module top;

	import axi_pkg::*;


	reg clock;
	reg reset;

	axi_if if0(.sig_clock(clock),.sig_reset(reset));



initial begin
	//axi_write_test_tb
	uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.tb0.*","vif",if0);
//	$display("TOME TOME TOME ");
 	run_test("base_test");

end

initial begin
	 reset <= 1'b1;
	 clock <= 1'b0;
   // #6 reset <= 1'b1;
end

always
	#50 clock =~ clock;
endmodule


`endif