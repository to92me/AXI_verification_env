`ifndef AXI_MASTER_WRITE_SEQUENCER_SVH
`define AXI_MASTER_WRITE_SEQUENCER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_sequencer
//
//------------------------------------------------------------------------------

class axi_master_write_sequencer extends uvm_sequencer #(axi_frame);

	// Configuration object
	axi_master_config config_obj;


`uvm_component_utils_begin(axi_master_write_sequencer)
	 `uvm_field_object(config_obj, UVM_REFERENCE | UVM_DEFAULT)
 `uvm_component_utils_end

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(axi_master_config)::get(this, "", "config_obj", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : axi_master_write_sequencer

`endif
