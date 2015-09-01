// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_slave_read_sequencer.sv
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
* Description : slave sequencer (contains aribtration)
*
* Classes :	1. axi_slave_read_sequencer
*
* Functions :	1. new (string name, uvm_component parent)
*				2. void build_phase(uvm_phase phase)
**/
// -----------------------------------------------------------------------------

`ifndef AXI_SLAVE_READ_SEQUENCER_SV
`define AXI_SLAVE_READ_SEQUENCER_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_read_sequencer
//
//------------------------------------------------------------------------------
class axi_slave_read_sequencer extends uvm_sequencer #(axi_read_base_frame);

	// Configuration object
	axi_slave_config config_obj;

	axi_slave_read_arbitration arbit;

	// register
	`uvm_component_utils_begin(axi_slave_read_sequencer)
		`uvm_field_object(config_obj, UVM_DEFAULT)
		`uvm_field_object(arbit, UVM_DEFAULT)
	`uvm_component_utils_end

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the configuration object
		if(!uvm_config_db#(axi_slave_config)::get(this, "", "axi_slave_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		arbit = axi_slave_read_arbitration::type_id::create("arbit", this);
	endfunction : new

endclass : axi_slave_read_sequencer

`endif