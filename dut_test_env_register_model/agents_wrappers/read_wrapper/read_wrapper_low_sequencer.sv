`ifndef AXI_READ_WRAPPER_LOW_SEQUENCER_SVH
`define AXI_READ_WRAPPER_LOW_SEQUENCER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_read_wrapper_low_sequencer extends uvm_sequencer#(dut_frame);

	uvm_seq_item_pull_port#(dut_frame)		upper_seq_item_port;


	`uvm_component_utils(axi_read_wrapper_low_sequencer)


	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		upper_seq_item_port = new("AxiReadWrapperLowSequencerUpperPullPort");
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

endclass : axi_read_wrapper_low_sequencer


`endif