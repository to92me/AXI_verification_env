`ifndef DUT_VIF_SVH
`define DUT_VIF_SVH
//------------------------------------------------------------------------------
//
// INTERFACE: uvc_company_uvc_name_if
//
//------------------------------------------------------------------------------

// Just in case you need them
`include "uvm_macros.svh"

interface dut_helper_vif(input sig_fclock);

	logic irq;
	logic dout;

	endinterface : dut_helper_vif

`endif