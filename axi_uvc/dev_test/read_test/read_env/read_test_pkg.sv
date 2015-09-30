`ifndef READ_TEST_PKG_SV
`define READ_TEST_PKG_SV

package read_test_pkg;

	typedef class axi_read_test_config;

	`include "axi_uvc/sv/axi_pkg.sv"
	import axi_pkg::*;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "axi_uvc/dev_test/read_test/read_env/axi_read_test_config.sv"
	`include "axi_uvc/dev_test/read_test/read_env/axi_read_tb.sv"
	
endpackage

`endif