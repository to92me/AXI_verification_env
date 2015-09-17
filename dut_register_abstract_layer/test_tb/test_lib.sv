/******************************************************************************
	* DVT CODE TEMPLATE: Base test
	* Created by root on Sep 17, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

class dut_register_model_test_lib_base extends uvm_test;

	// TB instance
	uvc_company_uvc_name_tb tb0;

	// Table printer instance(optional)
	uvm_table_printer printer;

	// TODO: Add fields here


	`uvm_component_utils(dut_register_model_test_lib_base)

	// new - constructor
	function new(string name = "base_test", uvm_component parent);
		super.new(name,parent);
		printer = new();
	endfunction: new

	// build_phase
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		tb0 =  uvc_company_uvc_name_tb::type_id::create("tb0",this);
	endfunction

	// run_phase
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		// Print the UVM instance tree at the beginning of simulation (optional)
		printer.knobs.depth = 5;
		this.print(printer);
	endtask
endclass



