/******************************************************************************
	* DVT CODE TEMPLATE: monitor
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_read_monitor
//
//------------------------------------------------------------------------------

class axi_slave_read_monitor extends uvm_monitor;

	// This property is the virtual interfaced needed for this component to drive
	// and view HDL signals.
	virtual axi_if vif;

	// Configuration object
	axi_config config_obj;

	// The following two bits are used to control whether checks and coverage are
	// done both in the monitor class and the interface.
	bit checks_enable = 1;
	bit coverage_enable = 1;

	protected int unsigned num_trans = 0;

	// TLM Ports
	uvm_analysis_port #(axi_read_single_frame) data_collected_port;
	uvm_analysis_port #(axi_frame_base) addr_collected_port;

	// allow sequencer access
	uvm_blocking_peek_imp#(axi_frame_base, axi_slave_read_monitor) addr_trans_export;

	// The following property holds the transaction information currently
	// begin captured (by the collect_address_phase and data_phase methods).
	axi_read_single_frame trans_data_channel;
	axi_frame_base trans_addr_channel;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_slave_read_monitor)
		`uvm_field_object(config_obj, UVM_DEFAULT)
		`uvm_field_int(checks_enable, UVM_DEFAULT)
		`uvm_field_int(coverage_enable, UVM_DEFAULT)
		`uvm_field_int(num_trans, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		trans_data_channel = axi_read_single_frame::type_id::create("trans_data_channel");
		trans_addr_channel = axi_frame_base::type_id::create("trans_addr_channel");
		data_collected_port = new("data_collected_port", this);
		addr_collected_port = new("addr_collected_port", this);
		addr_trans_export = new("addr_trans_export", this);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual task collect_transactions();
	extern virtual function void perform_transfer_checks();
	extern virtual function void perform_transfer_coverage();

endclass : axi_slave_read_monitor

	// build_phase
	function void axi_slave_read_monitor::build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
		// Propagate the configuration object
		if(!uvm_config_db#(axi_config)::get(this, "", "config_obj", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

	// run_phase
	task axi_slave_read_monitor::run_phase(uvm_phase phase);
		process main; // used by the reset handling mechanism
		// Start monitoring only after an initial reset pulse
		@(negedge vif.sig_reset);
		do
			@(posedge vif.sig_clock);
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
	task axi_slave_read_monitor::collect_transactions();
		forever begin
			@(posedge vif.sig_clock);
			// TODO : Fill this place with the logic for collecting the transfer data
			// ...
			if (vif.arvalid && vif.arready)
				begin
					trans_addr_channel.addr = vif.araddr;
					trans_addr_channel.id = vif.arid;
					trans_addr_channel.len = vif.arlen;
					trans_addr_channel.size = vif.arsize;
					trans_addr_channel.burst_type = vif.arburst;
					trans_addr_channel.lock = vif.arlock;
					trans_addr_channel.cache = vif.arcache;
					trans_addr_channel.prot = vif.arprot;
					trans_addr_channel.qos = vif.arqos;
					trans_addr_channel.region = vif.arregion;
					// user
				end

			if (vif.rvalid && vif.rready)
				begin
					trans_data_channel.data = vif.rdata;
					trans_data_channel.id = vif.rid;
					trans_data_channel.resp = vif.rresp;
					trans_data_channel.last = vif.rlast;
					// user
				end

			`uvm_info(get_full_name(), $sformatf("Transfer collected :\n!s",! trans_data_channel.sprint()), UVM_MEDIUM)
			`uvm_info(get_full_name(), $sformatf("Transfer collected :\n!s",! trans_addr_channel.sprint()), UVM_MEDIUM)
			if (checks_enable)
				perform_transfer_checks();
			if (coverage_enable)
				perform_transfer_coverage();
			data_collected_port.write(trans_data_channel);
			addr_collected_port.write(trans_addr_channel);
		end
	endtask : collect_transactions

	// perform_transfer_checks
	function void axi_slave_read_monitor::perform_transfer_checks();
		// TODO : Perform checks here
		// ...
	endfunction : perform_transfer_checks

	// perform_transfer_coverage
	function void axi_slave_read_monitor::perform_transfer_coverage();
		cov_trans.sample();
		// TODO : Collect coverage here
		// ...
	endfunction : perform_transfer_coverage
