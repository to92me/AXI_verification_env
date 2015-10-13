`ifndef DUT_REGISTER_MODEL_TOP_SEQUENCER_SVH
`define DUT_REGISTER_MODEL_TOP_SEQUENCER_SVH

// -----------------------------------------------------------------------------
/**
* Project :  DUT TESTING WITH REGISTER MODEL
*
* File : top_sequencer.sv
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
* Description :top sequencer will recieve sequence items from register model adapter
*
*/
// -----------------------------------------------------------------------------

class dut_register_model_top_sequencer extends uvm_sequencer#(dut_frame);


	`uvm_component_utils(dut_register_model_top_sequencer)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

endclass



`endif