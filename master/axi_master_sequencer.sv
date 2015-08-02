/******************************************************************************
	* DVT CODE TEMPLATE: sequencer
	* Created by root on Aug 2, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_sequencer
//
//------------------------------------------------------------------------------

class uvc_company_uvc_name_sequencer extends uvm_sequencer #(uvc_company_uvc_name_item);

	// Configuration object
	uvc_company_uvc_name_config_obj config_obj;
	
	// TODO: Add fields here
	

	`uvm_component_utils(uvc_company_uvc_name_sequencer)

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the configuration object
		if(!uvm_config_db#(uvc_company_uvc_name_config_obj)::get(this, "", "config_obj", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : uvc_company_uvc_name_sequencer
