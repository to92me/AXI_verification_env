`ifndef AXI_MASTER_WRITE_COVERAGE_SKELETON_SVH_TOME
`define AXI_MASTER_WRITE_COVERAGE_SKELETON_SVH_TOME

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_master_write_coverage_skeleton extends axi_master_write_coverage_base;


	`uvm_component_utils(axi_master_write_coverage_skeleton)


	// add new covergroups

	function new (string name, uvm_component parent);
		super.new(name, parent);


	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern task sampleAddr();
	extern task sampleData();
	extern task sampleResponse();

endclass : axi_master_write_coverage_skeleton

	task axi_master_write_coverage_skeleton::sampleAddr();
		// covergroup.sample();
	endtask

	task axi_master_write_coverage_skeleton::sampleData();
		// covergroup.sample();
	endtask

	task axi_master_write_coverage_skeleton::sampleResponse();
		// covergroup.sample();
	endtask

`endif