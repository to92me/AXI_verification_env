/******************************************************************************
	* DVT CODE TEMPLATE: monitor
	* Created by root on Aug 2, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_monitor
//
//------------------------------------------------------------------------------

class uvc_company_uvc_name_monitor extends uvm_monitor;

	// This property is the virtual interfaced needed for this component to drive
	// and view HDL signals.
	protected virtual uvc_company_uvc_name_if vif;

	// Configuration object
	uvc_company_uvc_name_config_obj config_obj;

	// The following two bits are used to control whether checks and coverage are
	// done both in the monitor class and the interface.
	bit checks_enable = 1;
	bit coverage_enable = 1;

	uvm_analysis_port #(uvc_company_uvc_name_item) item_collected_port;

	// The following property holds the transaction information currently
	// begin captured (by the collect_address_phase and data_phase methods).
	protected uvc_company_uvc_name_item trans_collected;

	// Transfer collected covergroup
	covergroup cov_trans;
		option.per_instance = 1;
		// TODO: Fill this place with relevant cover points

	endgroup : cov_trans

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(uvc_company_uvc_name_monitor)
		`uvm_field_int(checks_enable, UVM_DEFAULT)
		`uvm_field_int(coverage_enable, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		cov_trans = new();
		cov_trans.set_inst_name({get_full_name(), ".cov_trans"});
		trans_collected = new();
		item_collected_port = new("item_collected_port", this);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual uvc_company_uvc_name_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
		// Propagate the configuration object
		if(!uvm_config_db#(uvc_company_uvc_name_config_obj)::get(this, "", "config_obj", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

	// run_phase
	virtual task run_phase(uvm_phase phase);
		process main; // used by the reset handling mechanism
		// Start monitoring only after an initial reset pulse
		@(negedge vif.sig_reset);
		do
			@(posedge vif.clock);
		while(vif.sig_reset!==1);
		// Start monitoring here with reset handling mechanism
		forever begin
			fork
				// Start the monitoring thread
				begin
					main=process::self();
					collect_transactions();
				end
				// Monitor the reset signal
				begin
					@(negedge vif.sig_reset);
					reset_monitor();
					if(main) main.kill();
				end
			join_any
		end
	endtask : run_phase

	// collect_transactions
	virtual protected task collect_transactions();
		forever begin
			@(posedge vif.sig_clock);
			// TODO : Fill this place with the logic for collecting the transfer data
			// ...
			`uvm_info(get_full_name(), $sformatf("Transfer collected :\n!s",! trans_collected.sprint()), UVM_MEDIUM)
			if (checks_enable)
				perform_transfer_checks();
			if (coverage_enable)
				perform_transfer_coverage();
			item_collected_port.write(trans_collected);
		end
	endtask : collect_transactions

	// perform_transfer_checks
	virtual protected function void perform_transfer_checks();
		// TODO : Perform checks here
		// ...
	endfunction : perform_transfer_checks

	// perform_transfer_coverage
	virtual protected function void perform_transfer_coverage();
		cov_trans.sample();
		// TODO : Collect coverage here
		// ...
	endfunction : perform_transfer_coverage

endclass : uvc_company_uvc_name_monitor
