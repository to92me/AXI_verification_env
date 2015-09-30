`ifndef AXI_WRITE_WRAPPER_TOP_SEQUENCER_SVH
`define AXI_WRITE_WRAPPER_TOP_SEQUENCER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

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