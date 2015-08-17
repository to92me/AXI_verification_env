`ifndef AXI_WRITE_TEST_CONFIG
`define AXI_WRITE_TEST_CONFIG

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_config_obj
//
//------------------------------------------------------------------------------

class axi_write_test_config extends axi_config;

	function new(string name = "axi_write_test_config");
		super.new(name);
		this.number_of_slaves = 10;
		this.createConfiguration();
	endfunction: new

endclass : axi_write_test_config


`endif