`ifndef AXI_CONFIG_SVH
`define AXI_CONFIG_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_config_obj
//
//------------------------------------------------------------------------------


class axi_config extends uvm_object;


	rand int number_of_slaves;
	axi_slave_config slave_list[$];
	axi_master_config master;
	bit has_checks = 1;
	bit has_coverage = 1;
	slave_config_factory factory;

	constraint number_of_slaves_scs{
		number_of_slaves inside {[5 : 20]};
	}

`uvm_object_utils_begin(axi_config)
	 `uvm_field_int(number_of_slaves, UVM_DEFAULT)
	 `uvm_field_queue_object(slave_list, UVM_DEFAULT)
	 `uvm_field_object(master, UVM_DEFAULT)
	 `uvm_field_int(has_checks, UVM_DEFAULT)
	 `uvm_field_int(has_coverage, UVM_DEFAULT)
 `uvm_object_utils_end

	// new - constructor
	function new(string name = "axi_config");
		super.new(name);
	endfunction: new

	extern function void createConfiguration();

endclass : axi_config

	function void axi_config::createConfiguration();
		master = axi_master_config::type_id::create("master");
		factory = slave_config_factory::type_id::create("slave_factory");
		factory.createSlaves(slave_list, number_of_slaves);
	endfunction

`endif