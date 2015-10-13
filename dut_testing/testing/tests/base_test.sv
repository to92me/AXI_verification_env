// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : base_test.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : contains test for the register model
*
* Test : base_test
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// TEST: base_test
//
//------------------------------------------------------------------------------
// -----------------------------------------------------------------------------
/**
*	Description : base test
**/
// -----------------------------------------------------------------------------
class base_test extends uvm_test;

	dut_register_model_tb tb0;
	uvm_table_printer printer;
	dut_register_block						register_model;
	`uvm_component_utils(base_test)

	function new(string name = "base_test", uvm_component parent);
		super.new(name,parent);
		printer = new();
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		register_model	= dut_register_block::type_id::create("DutRegisterModelBlock", 	this);
		register_model.build();

		set_config_int("*", "recording_detail", UVM_FULL);
		uvm_config_int::set(this, "tb0.*", "coverage_enable", 1);

		tb0 =  dut_register_model_tb::type_id::create("tb0",this);
		tb0.register_model = register_model;

		uvm_config_int::set(this, "*", "master_ready_rand_enable", 0);

		uvm_config_wrapper::set(this, "tb0.env.DutRegisterModelLowSequencer.run_phase",
          "default_sequence", dut_register_model_lower_sequence::get_type());

		uvm_config_wrapper::set(this, "tb0.env.AxiWriteWrapperAgent.AxiWriteWrapperLowSequencer.run_phase",
          "default_sequence", axi_write_wrapper_sequence::get_type());

		uvm_config_wrapper::set(this, "tb0.env.AxiReadWrapperAgent.AxiReadWrapperLowSequencer.run_phase",
          "default_sequence", axi_read_wrapper_sequence::get_type());

		set_config_string("*","axi_write_configuration","FullSpeed");

	endfunction : build_phase

	// run_phase
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		printer.knobs.depth = 5;
	endtask

	function void start_of_simulation_phase( uvm_phase phase );
    	super.start_of_simulation_phase( phase );
   endfunction: start_of_simulation_phase

endclass : base_test