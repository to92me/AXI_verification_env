/******************************************************************************
	* DVT CODE TEMPLATE: component
	* Created by root on Sep 1, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_monitor_config_manager extends uvm_component;


	`uvm_component_utils(axi_slave_write_monitor_config_manager)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

endclass : axi_slave_write_monitor_config_manager
