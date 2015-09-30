// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : dut_config.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : test configuration for testing the counter
*
* Classes :	dut_config
**/
// -----------------------------------------------------------------------------

`ifndef DUT_CONFIG_SV
`define DUT_CONFIG_SV

//------------------------------------------------------------------------------
//
// CLASS: dut_config
//
//------------------------------------------------------------------------------
/**
* Description : test configuration - no slaves
*
* Functions : 1. new (string name, uvm_component parent)
**/
// -----------------------------------------------------------------------------
class dut_config extends axi_config;

	`uvm_object_utils(dut_config)

	function new(string name = "axi_write_test_config");
		super.new(name);
		`uvm_info(get_name(),$sformatf("Creating test config"), UVM_LOW)
		this.number_of_slaves = 0;
		this.createConfiguration();
	endfunction: new

endclass : dut_config

`endif