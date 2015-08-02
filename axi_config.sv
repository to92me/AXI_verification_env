/******************************************************************************
	* DVT CODE TEMPLATE: configuration object
	* Created by root on Aug 2, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_config_obj
//
//------------------------------------------------------------------------------

class uvc_company_uvc_name_config_obj extends uvm_object;

	// Agent id
	int unsigned id = 0;

	// Agent name
	string name="0";

	// Is the agent is active or passive
	uvm_active_passive_enum is_active = UVM_ACTIVE;

	// Has checks
	bit has_checks = 1;

	// Has coverage
	bit has_coverage = 1;

	// TODO: Add other configuration parameters that you might need


	// UVM object utils macro
	// TODO : it's very important that you use these macros on all the
	// configuration fields that you want to propagate. If you miss any
	// field it will not be propagated correctly
	`uvm_object_utils_begin(uvc_company_uvc_name_config_obj)
		`uvm_field_int(id,UVM_DEFAULT)
		`uvm_field_string(name,UVM_DEFAULT)
		`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
		`uvm_field_int(has_checks, UVM_DEFAULT)
		`uvm_field_int(has_coverage, UVM_DEFAULT)
	`uvm_object_utils_end

	// new - constructor
	function new(string name = "uvc_company_uvc_name_config_obj");
		super.new(name);
	endfunction: new

endclass : uvc_company_uvc_name_config_obj
