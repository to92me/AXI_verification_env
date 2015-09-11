// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_read_test_config_dut.sv
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
* Classes :	axi_read_test_config_dut
**/
// -----------------------------------------------------------------------------

`ifndef axi_read_test_config_dut
`define axi_read_test_config_dut

//------------------------------------------------------------------------------
//
// CLASS: axi_read_test_config_dut
//
//------------------------------------------------------------------------------
/**
* Description : test configuration - one slave
*
* Functions : 1. new (string name, uvm_component parent)
**/
// -----------------------------------------------------------------------------
class axi_read_test_config_dut extends axi_config;

	`uvm_object_utils(axi_read_test_config_dut)

	function new(string name = "axi_write_test_config");
		super.new(name);
		`uvm_info(get_name(),$sformatf("Creating test config"), UVM_LOW)
		this.number_of_slaves = 0;
		this.createConfiguration();
	endfunction: new

endclass : axi_read_test_config_dut


`endif