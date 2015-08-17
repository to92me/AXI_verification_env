`ifndef AXI_MASTER_CONFIG_SVH
`define AXI_MASTER_CONFIG_SVH

//------------------------------------------------------------------------------
//
// CLASS: axi_master_config
//
//for configuration master
//------------------------------------------------------------------------------

class axi_master_config extends uvm_object;


	string name;
	uvm_active_passive_enum is_active = UVM_ACTIVE;



	`uvm_object_utils_begin(axi_master_config)
		`uvm_field_string(name,UVM_DEFAULT)
		`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
	`uvm_object_utils_end

	// new - constructor
	function new(string name = "axi_master");
		super.new(name);
	endfunction: new

endclass : axi_master_config

`endif
