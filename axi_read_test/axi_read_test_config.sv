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
		this.slave_list[0].start_address = 0;
		this.slave_list[0].end_address = 4'hFFFF;
	endfunction: new

endclass : axi_read_test_config


`endif