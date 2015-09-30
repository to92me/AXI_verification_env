`ifndef AXI_WRITE_CONFIGURATION_REGISTER_SVH
`define AXI_WRITE_CONFIGURATION_REGISTER_SVH




`include "axi_uvc/configurations/full_speed.sv"
`include "axi_uvc/configurations/correct_data_delay_speed.sv"


class axi_write_configuration_register extends uvm_component;
	axi_write_configuration_wrapper 		wrapper;


	// add new configuration
	axi_write_master_user_configuration  				conf0;
	axi_write_configuration_full_speed   				conf1;
	axi_write_configuration_correct_data_delay_speed	conf2;

	`uvm_component_utils(axi_write_configuration_register)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);

		//create new configuration
		conf0 = axi_write_master_user_configuration::type_id::create("UserConf0", this);
		conf1 = axi_write_configuration_full_speed::type_id::create("FullSpeed", this);
		conf2 = axi_write_configuration_correct_data_delay_speed::type_id::create("CorecctDataDealySpeed", this);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern function void  registerConfig();

endclass : axi_write_configuration_register

	function void axi_write_configuration_register::registerConfig();
		wrapper = axi_write_configuration_wrapper::getWraperInstance(this);

		// to set configuration use wrapper.registerConfiguration(configuratino_instance,
//										sould_this_configuration_be_used_as_one_of_random_configuration,
//										configuration_name)
//
// 		configuration name is name that is copared to config_string (scope "axi_write_configuration")

	 	void'(wrapper.registerConfiguration(conf0,	TRUE, 	10,"test_configuration"));
		void'(wrapper.registerConfiguration(conf1,	TRUE, 	10, conf1.get_name()));
		void'(wrapper.registerConfiguration(conf2,	TRUE, 	10, conf2.get_name()));

	endfunction


`endif