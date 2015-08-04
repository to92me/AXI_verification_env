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
	import uvm_pkg::*;
	`include "uvm_macros.svh"


class axi_config extends uvm_object;



	// Has checks
	bit has_checks = 1;

	// Has coverage
	bit has_coverage = 1;



	`uvm_object_utils_begin(axi_config)
		`uvm_field_int(id,UVM_DEFAULT)
		`uvm_field_string(name,UVM_DEFAULT)
		`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
		`uvm_field_int(has_checks, UVM_DEFAULT)
		`uvm_field_int(has_coverage, UVM_DEFAULT)
	`uvm_object_utils_end

	// new - constructor
	function new(string name = "axi_config");
		super.new(name);
	endfunction: new

endclass : uvc_company_uvc_name_config_obj
