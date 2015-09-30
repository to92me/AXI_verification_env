`ifndef AXI_READ_WRAPPER_LOW_SEQUENCER_SVH_
`define AXI_READ_WRAPPER_LOW_SEQUENCER_SVH_
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_read_wrapper_low_sequencer extends uvm_sequencer#(axi_read_whole_burst);

	uvm_seq_item_pull_port#(dut_frame)		upper_seq_item_port;
	axi_master_read_sequencer				read_sequencer;


	`uvm_component_utils(axi_read_wrapper_low_sequencer)


	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		upper_seq_item_port = new("AxiReadWrapperLowSequencerUpperPullPort", this);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	function void setReadSequencer(input axi_master_read_sequencer sqr_instance);
		this.read_sequencer = sqr_instance;
	endfunction

endclass : axi_read_wrapper_low_sequencer


`endif