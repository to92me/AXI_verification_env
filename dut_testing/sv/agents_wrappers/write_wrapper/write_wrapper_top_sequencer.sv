`ifndef AXI_WRITE_WRAPPER_TOP_SEQUENCER_SVH
`define AXI_WRITE_WRAPPER_TOP_SEQUENCER_SVH

// -----------------------------------------------------------------------------
/**
* Project :  DUT TESTING WITH REGISTER MODEL
*
* File : write_wrapper_top_sequencer.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Tomislav Tumbas
*
* E-Mail : tomislav.tumbas@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description :top sequencer will recieve sequence items upper sequencer
*
*/
// -----------------------------------------------------------------------------

class axi_write_wrapper_top_sequencer extends uvm_sequencer#(dut_frame);


	`uvm_component_utils(axi_write_wrapper_top_sequencer)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

endclass : axi_write_wrapper_top_sequencer

`endif