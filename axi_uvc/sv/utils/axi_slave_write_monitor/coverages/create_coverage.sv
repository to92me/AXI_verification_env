`ifndef AXI_slave_WRITE_COVERAGE_CREATOR_SVH
`define	AXI_slave_WRITE_COVERAGE_CREATOR_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_coverage_creator extends uvm_component;
	axi_slave_write_coverage 	coverage0;


	`uvm_component_utils(axi_slave_write_coverage_creator)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);

		coverage0	 = 	axi_slave_write_coverage::type_id::create("AxislaveWriteCoverage", this);


	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

endclass : axi_slave_write_coverage_creator


`endif