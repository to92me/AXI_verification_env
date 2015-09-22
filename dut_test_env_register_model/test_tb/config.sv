`ifndef DUT_MODEL_REGISTER_CONFIG_SVH
`define DUT_MODEL_REGISTER_CONFIG_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_config_obj
//
//------------------------------------------------------------------------------

class dut_register_model_config extends axi_config;

	`uvm_object_utils(dut_register_model_config)
	function new(string name = "axi_write_test_config");
		super.new(name);
		`uvm_info(get_name(),$sformatf("Creating test config"), UVM_LOW)
		this.number_of_slaves = 0;
		this.createConfiguration();
	endfunction: new

endclass : dut_register_model_config


`endif