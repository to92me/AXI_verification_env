`ifndef DUT_VIF_SVH
`define DUT_VIF_SVH

/**
* Project : DUT register model
*
* File : CFG.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Authors : Tomislav Tumbas
* 		    Andrea Erdeljan
*
* E-Mail : tomislav.tumbas@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : dut_helper_vif
*
*
**/

//------------------------------------------------------------------------------
//
// INTERFACE: dut_helper_vif
//
//------------------------------------------------------------------------------
//
// DESCRIPTION:
//			hepler interface are sgnals that DUT is using beside standard AXI
//			interface
//	 		this interface contains corresponding assertions
//
//------------------------------------------------------------------------------

import uvm_pkg::*;            // import the UVM library
`include "uvm_macros.svh"     // Include the UVM macros

interface dut_helper_vif(input sig_fclock, input sig_aclock, input sig_reset);

	// design output signals
	logic irq;
	logic dout;

	// helper flags for checking output signals
	bit dout_check = 0;
	bit irq_check = 0;
	bit dout_value = 0;
	bit irq_value = 0;

	// assertions
	always @(posedge sig_aclock) begin

	// DOUT high when counter > LOAD, else low
	// DUT Specification - 2.2 Signals, page 5
    assert_DOUT_SIGNAL_HIGH : assert property (
      disable iff(!dout_check || !sig_reset)
      (dout_value == 1 |-> dout == 1))
            else
              `uvm_error("ASSERTION_ERR","assert_DOUT_SIGNAL_HIGH: DOUT signal should be high")

    assert_DOUT_SIGNAL_LOW : assert property (
      disable iff(!dout_check || !sig_reset)
      (dout_value == 0 |-> dout == 0))
            else
              `uvm_error("ASSERTION_ERR","assert_DOUT_SIGNAL_LOW: DOUT signal should be low")

    // high when any of the interrupt bits in MIS are set, else low
    // DUT Specification - 2.2 Signals, page 5
    assert_IRQ_SIGNAL_HIGH : assert property (
      disable iff(!irq_check || !sig_reset)
      (irq_value == 1 |-> irq == 1))
            else
              `uvm_error("ASSERTION_ERR","assert_IRQ_SIGNAL_HIGH: IRQ signal should be high")

    assert_IRQ_SIGNAL_LOW : assert property (
      disable iff(!irq_check || !sig_reset)
      (irq_value == 0 |-> irq == 0))
            else
              `uvm_error("ASSERTION_ERR","assert_IRQ_SIGNAL_LOW: IRQ signal should be low")

	end

endinterface : dut_helper_vif

`endif