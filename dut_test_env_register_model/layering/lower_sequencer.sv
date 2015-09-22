`ifndef DUT_REGISTER_MODEL_LOWER_SEQUENCER_SVH
`define DUT_REGISTER_MODEL_LOWER_SEQUENCER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class dut_register_model_lower_sequencer extends uvm_sequencer#(dut_frame);

	`uvm_component_utils(dut_register_model_lower_sequencer)

	axi_read_wrapper_top_sequencer 			read_sequencer;
	axi_write_wrapper_top_sequencer			write_sequencer;

	uvm_seq_item_pull_port#(dut_frame) upper_seq_item_port;

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		upper_seq_item_port = new("DutRegisterModelLowerSequencer", this);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase



endclass : dut_register_model_lower_sequencer




`endif