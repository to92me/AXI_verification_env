`ifndef AXI_MASTER_WRITE_CHECKER_SKELETON_SVH
`define AXI_MASTER_WRITE_CHECKER_SKELETON_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_master_write_checker_skeleton extends uvm_component;


	`uvm_component_utils(axi_master_write_checker_skeleton)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern task main();

	extern task pushAddressItem(axi_write_address_collector_mssg mssg);
	extern task pushDataItem(axi_write_data_collector_mssg mssg);
	extern task pushResponseItem(axi_write_response_collector_mssg mssg);

	extern task reset();
	extern task printState();

endclass : axi_master_write_checker_skeleton


	task axi_master_write_checker_skeleton::pushAddressItem(input axi_write_address_collector_mssg mssg);
		// this methode will be called everytime when collector collects addr package from interface
		// here should be implemented functionaliti for this methode
	endtask

	task axi_master_write_checker_skeleton::pushDataItem(input axi_write_data_collector_mssg mssg);
		// this methode will be called everytime when collector collects data package from interface
		// here should be implemented functionaliti for this methode
	endtask

	task axi_master_write_checker_skeleton::pushResponseItem(input axi_write_response_collector_mssg mssg);
		// this methode will be called everytime when collector collects response package from interface
		// here should be implemented functionaliti for this methode
	endtask

	task axi_master_write_checker_skeleton::main();
		// this methode will be forked in build phase 
		// here should be implemented functionaliti for this methode
	endtask

	task axi_master_write_checker_skeleton::reset();
		// here should be implemented functionaliti for this methode
		// this methode will be called everytime when reset happends
	endtask

	task axi_master_write_checker_skeleton::printState();
		
	endtask

`endif