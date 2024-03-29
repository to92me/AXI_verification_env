`ifndef AXI_MASTER_WRITE_CHECKER_CREATOR_SVH
`define AXI_MASTER_WRITE_CHECKER_CREATOR_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_master_write_checker_creator extends uvm_component;

	axi_master_write_checker 			checker0;
	axi_master_write_burst_collector	burst_collector0;
	//axi_master_write_checker_skeleton checker1
	//


	`uvm_component_utils(axi_master_write_checker_creator)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);

		checker0 			= 	axi_master_write_checker::type_id::create("AxiMasterWriteChecker", this);
		burst_collector0	= 	axi_master_write_burst_collector::type_id::create("AxiMasterWriteCheckerBurstCollector", this);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

endclass : axi_master_write_checker_creator



`endif