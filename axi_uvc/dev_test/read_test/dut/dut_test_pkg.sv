`ifndef DUT_TEST_PKG_SV
`define DUT_TEST_PKG_SV

package dut_test_pkg;

	typedef class dut_config;
	typedef class axi_write_env;

	`include "axi_uvc/sv/axi_pkg.sv"
	import axi_pkg::*;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "axi_uvc/dev_test/read_test/dut/dut_config.sv"
	`include "axi_uvc/dev_test/read_test/dut/dut_tb.sv"
	`include "axi_uvc/dev_test/read_test/dut/axi_write_env.sv"

endpackage

`endif