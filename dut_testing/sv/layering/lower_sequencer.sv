`ifndef DUT_REGISTER_MODEL_LOWER_SEQUENCER_SVH
`define DUT_REGISTER_MODEL_LOWER_SEQUENCER_SVH

// -----------------------------------------------------------------------------
/**
* Project :  DUT TESTING WITH REGISTER MODEL
*
* File : low_sequencer.sv
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
* Description :low sequencer that is passing sequence items to wrapper agents
*
*/
// -----------------------------------------------------------------------------

class dut_register_model_lower_sequencer extends uvm_sequencer#(dut_frame);

	`uvm_component_utils(dut_register_model_lower_sequencer)

	axi_read_wrapper_top_sequencer 			read_sequencer;
	axi_write_wrapper_top_sequencer			write_sequencer;


	uvm_seq_item_pull_port#(dut_frame) upper_seq_item_port;

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		upper_seq_item_port = new("DutRegisterModelLowerSequencerPullPort", this);
	endfunction : build_phase

	function void setReadSequncer(input axi_read_wrapper_top_sequencer seqr_instance);
		this.read_sequencer = seqr_instance;
	endfunction

	function void setWriteSequencer(input axi_write_wrapper_top_sequencer seqr_instance);
		this.write_sequencer = seqr_instance;
	endfunction


endclass : dut_register_model_lower_sequencer




`endif