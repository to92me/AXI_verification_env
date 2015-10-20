// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : swreset_test.sv
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
* Test : swreset_test
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// TEST: swreset_test
//
//------------------------------------------------------------------------------
// -----------------------------------------------------------------------------
/**
*	Description : check SWRESET reg
**/
// -----------------------------------------------------------------------------
class swreset_test extends base_test;

	swreset_seq			reg_seq;

	`uvm_component_utils(swreset_test)

	function new(string name = "swreset_test", uvm_component parent);
		super.new(name,parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		reg_seq = swreset_seq::type_id::create("reg_seq", this);
		reg_seq.register_model = register_model;

	endfunction : build_phase

	// run_phase
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
	endtask

	task main_phase(uvm_phase phase);
		phase.raise_objection(this);
		reg_seq.start(tb0.dut_test_env.top_sequencer);
		phase.drop_objection(this);
	endtask

endclass : swreset_test