`ifndef DUT_MODEL_REGISTER_CONFIG_SVH
`define DUT_MODEL_REGISTER_CONFIG_SVH

// -----------------------------------------------------------------------------
/**
* Project :  DUT TESTING WITH REGISTER MODEL
*
* File : config.sv
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
* Description : configuration for axi_uvc
*
*/
// -----------------------------------------------------------------------------

class dut_register_model_config extends axi_config;

	`uvm_object_utils(dut_register_model_config)
	function new(string name = "axi_write_test_config");
		super.new(name);
		`uvm_info(get_name(),$sformatf("Creating test config"), UVM_LOW)
		this.number_of_slaves = 0;
		this.createConfiguration();
	endfunction

endclass : dut_register_model_config


`endif