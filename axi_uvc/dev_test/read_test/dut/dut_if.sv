// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : dut_if.sv
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
* Description : virtual interface for the dut
*
* Classes : dut_if
**/
// -----------------------------------------------------------------------------

import uvm_pkg::*;            // import the UVM library
`include "uvm_macros.svh"     // Include the UVM macros

interface dut_if (input reset, input fclk);

	logic irq_o;
	logic dout_o;

endinterface : dut_if