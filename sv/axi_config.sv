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
	`include "sv/master/axi_master_config.sv"
	`include "sv/slave/axi_slave_config.sv"

class axi_config extends uvm_object;


	rand int number_of_slaves;
	axi_slave_config slve_list[number_of_slaves];
	axi_master_config master;
	bit has_checks = 1;
	bit has_coverage = 1;

`uvm_object_utils_begin(axi_config)
	 `uvm_field_int(number_of_slaves, UVM_DEFAULT)
	 `uvm_field_object(master, UVM_DEFAULT)
	 `uvm_field_int(has_checks, UVM_DEFAULT)
	 `uvm_field_int(has_coverage, UVM_DEFAULT)
 `uvm_object_utils_end

	// new - constructor
	function new(string name = "axi_config");
		super.new(name);
	endfunction: new

endclass : axi_config
