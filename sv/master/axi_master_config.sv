`ifndef AXI_MASTER_CONFIG_SVH
`define AXI_MASTER_CONFIG_SVH

/****************************************************************
* Project : AXI UVC
*
* File : data_driver.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Tomislav Tumbas
*
* E-Mail : tomislav.tumbas@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : data bus driving util
*
* Classes :	1.axi_master_write_scheduler_package2_0
******************************************************************/

//-------------------------------------------------------------------------------------
//
// CLASS: axi_master_config
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//		this class is axi master configuration
//		axi_master_has only one information: axi_maser_name
//--------------------------------------------------------------------------------------


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
