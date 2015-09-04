// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_virtual_sequencer.sv
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
* Description : virtual sequencer
*
* Classes : axi_virtual_sequencer
**/
// -----------------------------------------------------------------------------

`ifndef AXI_VIRTUAL_SEQUENCER_SV
`define AXI_VIRTUAL_SEQUENCER_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_virtual_sequencer
//
//------------------------------------------------------------------------------
/**
* Description : virtual sequencer
*
* Functions :	1. new (string name, uvm_component parent)
*				2. build_phase(uvm_phase phase)
**/
// -----------------------------------------------------------------------------
class axi_virtual_sequencer extends uvm_sequencer;

	// Configuration object
	axi_config config_obj;

	axi_master_read_sequencer read_seqr;

	`uvm_component_utils(axi_virtual_sequencer)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);

endclass : axi_virtual_sequencer

//------------------------------------------------------------------------------
/**
* Function : build_phase
* Purpose : build
* Parameters :	phase - uvm phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_virtual_sequencer::build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the configuration object
		if(!uvm_config_db#(axi_config)::get(this, "", "axi_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

`endif