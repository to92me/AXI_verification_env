`ifndef AXI_MASTER_WRITE_CHECKER_SVH
`define AXI_MASTER_WRITE_CHECKER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_master_write_checker extends uvm_component;


	`uvm_component_utils(axi_master_write_checker)

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

endclass : axi_master_write_checker


	task axi_master_write_checker::pushAddressItem(input axi_write_address_collector_mssg mssg);

	endtask

	task axi_master_write_checker::pushDataItem(input axi_write_data_collector_mssg mssg);


	endtask

	task axi_master_write_checker::pushResponseItem(input axi_write_response_collector_mssg mssg);

	endtask

	task axi_master_write_checker::main();


	endtask

`endif