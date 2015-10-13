// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : combined_test.sv
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
* Test : combined_test
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// TEST: combined_test
//
//------------------------------------------------------------------------------
// -----------------------------------------------------------------------------
/**
*	Description : combines all previusly ran tests
**/
// -----------------------------------------------------------------------------
class combined_test extends base_test;

	// sequences
	count_seq count_s;
	iir_seq iir_s;
	load_seq load_s;
	match_seq match_s;
	swreset_seq swreset_s;

	`uvm_component_utils(combined_test)

	function new(string name = "combined_test", uvm_component parent);
		super.new(name,parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		count_s = count_seq::type_id::create("count_s", this);
		count_s.register_model = register_model;

		iir_s = iir_seq::type_id::create("iir_s", this);
		iir_s.register_model = register_model;

		load_s = load_seq::type_id::create("load_s", this);
		load_s.register_model = register_model;

		match_s = match_seq::type_id::create("match_s", this);
		match_s.register_model = register_model;

		swreset_s = swreset_seq::type_id::create("swreset_s", this);
		swreset_s.register_model = register_model;

	endfunction : build_phase

	// run_phase
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
	endtask

	task main_phase(uvm_phase phase);
			phase.raise_objection(this);

			// sequences
			count_s.start(tb0.dut_test_env.top_sequencer);
			iir_s.start(tb0.dut_test_env.top_sequencer);
			load_s.start(tb0.dut_test_env.top_sequencer);
			match_s.start(tb0.dut_test_env.top_sequencer);
			swreset_s.start(tb0.dut_test_env.top_sequencer);
			iir_s.start(tb0.dut_test_env.top_sequencer);
			count_s.start(tb0.dut_test_env.top_sequencer);
			match_s.start(tb0.dut_test_env.top_sequencer);
			load_s.start(tb0.dut_test_env.top_sequencer);
			iir_s.start(tb0.dut_test_env.top_sequencer);

			phase.drop_objection(this);
	endtask

endclass : combined_test