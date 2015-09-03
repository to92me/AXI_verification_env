// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_read_test_config.sv
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
* Description : test configuration for read
*
* Classes :	axi_read_test_config
**/
// -----------------------------------------------------------------------------

`ifndef AXI_READ_TEST_CONFIG
`define AXI_READ_TEST_CONFIG

//------------------------------------------------------------------------------
//
// CLASS: axi_read_test_config
//
//------------------------------------------------------------------------------

class axi_read_test_config extends axi_config;

	`uvm_object_utils(axi_read_test_config)

	function new(string name = "axi_write_test_config");
		super.new(name);
		`uvm_info(get_name(),$sformatf("Creating test config"), UVM_LOW)
		this.number_of_slaves = 1;
		this.createConfiguration();
	endfunction: new

endclass : axi_read_test_config


`endif