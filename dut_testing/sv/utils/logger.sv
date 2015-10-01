`ifndef DUT_TESTING_LOGGER
`define DUT_TESTING_LOGGER



class dut_testing_logger extends uvm_component;

	`uvm_component_utils(dut_testing_logger)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase



endclass : dut_testing_logger


`endif