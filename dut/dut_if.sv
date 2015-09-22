

import uvm_pkg::*;            // import the UVM library
`include "uvm_macros.svh"     // Include the UVM macros

interface dut_if (input reset, input fclk);

	logic irq_o;
	logic dout_o;

endinterface : dut_if