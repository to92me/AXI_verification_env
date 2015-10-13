`ifndef DUT_REGISTER_MODEL_TB_SVH
`define DUT_REGISTER_MODEL_TB_SVH

// -----------------------------------------------------------------------------
/**
* Project :  DUT TESTING WITH REGISTER MODEL
*
* File : tb.sv
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
* Description : test bench
*
*/
// -----------------------------------------------------------------------------



class  dut_register_model_tb extends uvm_env;


  	dut_register_model_env				dut_test_env;
	axi_write_configuration_wrapper 	configuration_wrapper;
	axi_write_conf 						uvc_configuration;


	dut_register_model_config 			config_obj;

	dut_register_block					register_model;


//  // virtual seqr
//  axi_virtual_sequencer 			virtual_seqr;

  //

  `uvm_component_utils_begin(dut_register_model_tb)

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

		// 	set MASTER CONFIG OBJ
	    config_obj = dut_register_model_config::type_id::create("config_obj");
	    uvm_config_db#(axi_config)::set(this, "*", "axi_config", config_obj);

	    uvm_config_db#(axi_master_config)::set(this, "*", "axi_master_config", config_obj.master);

		// create and set UVM_CONFIGURATION
	    configuration_wrapper = axi_write_configuration_wrapper::getWraperInstance(this);
	    uvc_configuration = configuration_wrapper.generateConfigurationObject();
	    uvm_config_db#(axi_write_conf)::set(this, "*", "uvc_write_config", uvc_configuration);

		// create nad build REGISTER MODEL


		// create TB
		dut_test_env = dut_register_model_env::type_id::create("env", this);
		// set register model in env
		dut_test_env.register_block = register_model;


	endfunction


	function void dut_register_model_tb::connect_phase(input uvm_phase phase);
	    super.connect_phase(phase);
    	//virtual_seqr.read_seqr = read_env.read_master.sequencer;
		//virtual_seqr.write_seqr = write_env.master.sequencer;
	endfunction


`endif