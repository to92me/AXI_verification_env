/******************************************************************************
	* DVT CODE TEMPLATE: configuration object
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_config
//
//------------------------------------------------------------------------------

class axi_slave_config extends uvm_object;


	string name="0";

	rand uvm_active_passive_enum is_active = UVM_ACTIVE;
	rand int start_address;
	rand int end_address;

	constraint addr_cst {start_address <= end_address; }


	`uvm_object_utils_begin(axi_slave_config)
		`uvm_field_string(name,UVM_DEFAULT)
		`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
		`uvm_field_int(start_address,UVM_DEFAULT)
		`uvm_field_int(end_address,UVM_DEFAULT)
	`uvm_object_utils_end

	// new - constructor
	function new(string name = "axi_slave_config");
		super.new(name);
	endfunction: new

endclass : axi_slave_config
