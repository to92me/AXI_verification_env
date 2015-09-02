

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class uvc_company_uvc_name_component extends uvm_component;

	// TODO: Add fields here


	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils(uvc_company_uvc_name_component)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

endclass : uvc_company_uvc_name_component
