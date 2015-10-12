// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : iir_test.sv
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
* Test : iir_test
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// TEST: iir_test
//
//------------------------------------------------------------------------------
// -----------------------------------------------------------------------------
/**
*	Description : check COUNT reg
**/
// -----------------------------------------------------------------------------
class iir_test extends uvm_test;

	dut_register_model_tb tb0;
	uvm_table_printer printer;
	dut_register_block						register_model;
	iir_seq			register_model_logger_seq;

	`uvm_component_utils(iir_test)

	function new(string name = "iir_test", uvm_component parent);
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

		register_model_logger_seq = iir_seq::type_id::create("register_model_logger_seq", this);
		register_model_logger_seq.register_model = register_model;

		uvm_config_wrapper::set(this, "tb0.env.DutRegisterModelLowSequencer.run_phase",
          "default_sequence", dut_register_model_lower_sequence::get_type());

		uvm_config_wrapper::set(this, "tb0.env.AxiWriteWrapperAgent.AxiWriteWrapperLowSequencer.run_phase",
          "default_sequence", axi_write_wrapper_sequence::get_type());

		uvm_config_wrapper::set(this, "tb0.env.AxiReadWrapperAgent.AxiReadWrapperLowSequencer.run_phase",
          "default_sequence", axi_read_wrapper_sequence::get_type());

	endfunction : build_phase

	// run_phase
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		printer.knobs.depth = 5;
	endtask

	task main_phase(uvm_phase phase);
			phase.raise_objection(this);
			register_model_logger_seq.start(tb0.dut_test_env.top_sequencer);
			phase.drop_objection(this);
	endtask

	function void start_of_simulation_phase( uvm_phase phase );
    	super.start_of_simulation_phase( phase );
   endfunction: start_of_simulation_phase

endclass : iir_test