`ifndef DUT_REGISTER_MODEL_TOP_SEQUENCER_SVH
`define DUT_REGISTER_MODEL_TOP_SEQUENCER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

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