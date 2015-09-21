/******************************************************************************
* DVT CODE TEMPLATE: TB class
* Created by root on Sep 17, 2015
* uvc_company = uvc_company, uvc_name = uvc_name uvc_if = uvc_if
*******************************************************************************/

class  dut_register_model_tb extends uvm_env;


  // READ
  axi_env read_env;

  // WRITE
  axi_write_env write_env;
  axi_write_configuration_wrapper configuration_wrapper;
  axi_write_conf uvc_configuration;

  // configuration object
  axi_read_test_config_dut config_obj;

  // virtual seqr
  axi_virtual_sequencer virtual_seqr;

  //

  `uvm_component_utils_begin(axi_read_counter_tb)
    `uvm_field_object(read_env, UVM_ALL_ON)
    `uvm_field_object(config_obj, UVM_ALL_ON)
     `uvm_field_object(write_env, UVM_ALL_ON)
     `uvm_field_object(configuration_wrapper, UVM_DEFAULT)
     `uvm_field_object(uvc_configuration, UVM_DEFAULT)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass


	function void dut_register_model_tb::build_phase(input uvm_phase phase);
	    super.build_phase(phase);

	    config_obj = axi_read_test_config_dut::type_id::create("config_obj");
	    uvm_config_db#(axi_config)::set(this, "*", "axi_config", config_obj);

	    read_env = axi_env::type_id::create("read_env", this);
	    virtual_seqr = axi_virtual_sequencer::type_id::create("virtual_seqr", this);

	    configuration_wrapper = axi_write_configuration_wrapper::getWraperInstance(this);
	    uvc_configuration = configuration_wrapper.generateConfigurationObject();

	    uvm_config_db#(axi_write_conf)::set(this, "*", "uvc_write_config", uvc_configuration);

	    write_env  = axi_write_env::type_id::create("write_env", this);

	endfunction


	function void dut_register_model_tb::connect_phase(input uvm_phase phase);
	    super.connect_phase(phase);
    	virtual_seqr.read_seqr = read_env.read_master.sequencer;
		virtual_seqr.write_seqr = write_env.master.sequencer;
	endfunction
