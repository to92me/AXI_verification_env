`ifndef AXI_slave_WRITE_CHECKER_CREATOR_SVH
`define AXI_slave_WRITE_CHECKER_CREATOR_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_checker_creator extends uvm_component;

	axi_slave_write_checker checker0;
	//axi_slave_write_checker_skeleton checker1
	//


	`uvm_component_utils(axi_slave_write_checker_creator)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);

		checker0 = 	axi_slave_write_checker::type_id::create("AxislaveWriteChecker", this);

	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

endclass : axi_slave_write_checker_creator



`endif