/******************************************************************************
	* DVT CODE TEMPLATE: sequencer
	* Created by andrea on Aug 20, 2015
	* uvc_company = axi, uvc_name = virtual
*******************************************************************************/

`ifndef AXI_VIRTUAL_SEQUENCER_SV
`define AXI_VIRTUAL_SEQUENCER_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_virtual_sequencer
//
//------------------------------------------------------------------------------

class axi_virtual_sequencer extends uvm_sequencer;

	// Configuration object
	axi_config config_obj;

	axi_master_read_sequencer read_seqr;
	// TODO : add master write

	`uvm_component_utils(axi_virtual_sequencer)

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the configuration object
		if(!uvm_config_db#(axi_config)::get(this, "", "axi_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : axi_virtual_sequencer

`endif