`ifndef AXI_WRITE_CONFIGURATION_REGISTER_SVH
`define AXI_WRITE_CONFIGURATION_REGISTER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_write_configuration_register extends uvm_component;
	axi_write_configuration_wrapper 		wrapper;

	axi_write_master_user_configuration  conf0;

	`uvm_component_utils(axi_write_configuration_register)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		conf0 = axi_write_master_user_configuration::type_id::create("UserConf0", this);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		$display("TOME BILDING REGISTRATOR");
		//registerConfig();
	endfunction : build_phase

	extern function void  registerConfig();

endclass : axi_write_configuration_register

	function void axi_write_configuration_register::registerConfig();
		$display("++++++ TOME +++++ REGISTRING CONFIGURATIONS++++++++");
		wrapper = axi_write_configuration_wrapper::getWraperInstance(this);
		conf0.setConfigurations();
	 	void'(wrapper.registerConfiguration(conf0,TRUE, 10));
//	   	void'(wrapper.registerConfiguration(conf1,TRUE));


	endfunction


`endif