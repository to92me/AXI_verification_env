// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : dut_test_pkg.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : contains typedefs and includes for dut testing
*
* Classes : dut_test_pkg
**/
// -----------------------------------------------------------------------------

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