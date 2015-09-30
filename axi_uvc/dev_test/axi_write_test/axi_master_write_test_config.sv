`ifndef AXI_WRITE_TEST_CONFIG_SVH
`define AXI_WRITE_TEST_CONFIG_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_config_obj
//
//------------------------------------------------------------------------------

class axi_write_test_config extends axi_config;

	`uvm_object_utils(axi_write_test_config)
	function new(string name = "axi_write_test_config");
		super.new(name);
		`uvm_info(get_name(),$sformatf("Creating test config"), UVM_LOW)
		this.number_of_slaves = 1;
		this.createConfiguration();
	endfunction: new

endclass : axi_write_test_config


`endif