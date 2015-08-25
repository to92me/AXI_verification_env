`ifndef TEST_LIB_SVH
`define TEST_LIB_SVH

class base_test extends uvm_test;

	// TB instance
	axi_master_write_tb tb0;

	// Table printer instance(optional)
	uvm_table_printer printer;

	// TODO: Add fields here


`uvm_component_utils_begin(base_test)
	 `uvm_field_object(tb0, UVM_ALL_ON)
 `uvm_component_utils_end

	// new - constructor
	function new(string name = "base_test", uvm_component parent);
		super.new(name,parent);
		printer = new();
	endfunction: new

	// build_phase
	virtual function void build_phase(uvm_phase phase);


		 set_config_int("*", "recording_detail", UVM_FULL);
		 uvm_config_int::set(this, "tb0.*", "coverage_enable", 1);

		tb0 =  axi_master_write_tb::type_id::create("tb0",this);

		uvm_config_wrapper::set(this, "tb0.env.master_write_agent.sequencer.run_phase",
          "default_sequence", axi_master_write_sequence_lib_test1::get_type());


		super.build_phase(phase);
	endfunction

	// run_phase
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		// Print the UVM instance tree at the beginning of simulation (optional)
//		printer.knobs.depth = 5;
		phase.phase_done.set_drain_time(this, 2000000);
//		this.print(printer);
	endtask
endclass

//`include uvm_testcase1.sv
//`include uvm_testcase2.sv


`endif