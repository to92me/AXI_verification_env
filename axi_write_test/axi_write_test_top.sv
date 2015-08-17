`ifndef AXI_WRITE_TEST_TOP
`define AXI_WRITE_TEST_TOP


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

	uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.*","vif",if0);
	$display("TOME TOME TOME ");
 	run_test("base_test");

end

initial begin
	reset <= 1'b1;
	clock <= 1'b0;
end

always
	#5 clock =~ clock;
endmodule


`endif