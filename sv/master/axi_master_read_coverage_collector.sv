/******************************************************************************
	* DVT CODE TEMPLATE: coverage collector
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_coverage_collector
//
//------------------------------------------------------------------------------

class uvc_company_uvc_name_coverage_collector extends uvm_component;

	// Configuration object
	uvc_company_uvc_name_config_obj config_obj;

	// Transaction item collected from the monitor
	// (contains data to be covered)
	uvc_company_uvc_name_item monitor_item;
	
	// TLM connection to the monitor
	uvm_tlm_analysis_fifo#(uvc_company_uvc_name_item) monitor_port;
	
	// TODO: More items and TLM connections can be added if needed
	

	// Covergroup
	covergroup transaction_coverage;
		//add coverpoints here
	endgroup
	//you can add more covergroups

	// new - constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
		transaction_coverage=new;
	endfunction

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		monitor_port=new("monitor_port",this);
		// Propagate the configuration object
		if(!uvm_config_db#(uvc_company_uvc_name_config_obj)::get(this, "", "config_obj", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction : build_phase

	// run_phase
	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		fork
			begin
				forever begin
					monitor_port.get(monitor_item);
					// TODO : fetch data from other TLM ports
					transaction_coverage.sample();
					// TODO : sample other covergroups
				end 
			end
		join_none
	endtask : run_phase   

endclass : uvc_company_uvc_name_coverage_collector
