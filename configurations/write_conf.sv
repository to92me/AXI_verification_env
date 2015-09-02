/******************************************************************************
	* DVT CODE TEMPLATE: component
	* Created by root on Sep 2, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_write_conf extends uvm_object;

	// TODO: Add fields here


	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils(axi_write_conf)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

endclass : axi_write_conf
