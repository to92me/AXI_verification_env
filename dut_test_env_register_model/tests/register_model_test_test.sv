`ifndef DUT_REGISTER_MODEL_TEST_TEST_SVH
`define DUT_REGISTER_MODEL_TEST_TEST_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class dut_register_model_test_test extends dut_register_model_test_base;


	`uvm_component_utils(dut_register_model_test_test)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	virtual task body(uvm_phase phase);
		

		phase.raise_objection(this);
		
		
		

	endtask

endclass : dut_register_model_test_test


`endif