// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_master_read_sequencer.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : master sequencer
*
* Classes :	1. axi_master_read_sequencer
*
* Functions :	1. new (string name, uvm_component parent)
*				2. void build_phase(uvm_phase phase)
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// CLASS: axi_master_read_sequencer
//
//------------------------------------------------------------------------------

`ifndef AXI_MASTER_READ_SEQUENCER_SV
`define AXI_MASTER_READ_SEQUENCER_SV

class axi_master_read_sequencer extends uvm_sequencer #(axi_read_burst_frame);

	// Configuration object
	axi_master_config config_obj;

	`uvm_component_utils_begin(axi_master_read_sequencer)
		`uvm_field_object(config_obj, UVM_DEFAULT|UVM_REFERENCE)
	`uvm_component_utils_end

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the configuration object
		if(!uvm_config_db#(axi_master_config)::get(this, "", "axi_master_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : axi_master_read_sequencer

`endif