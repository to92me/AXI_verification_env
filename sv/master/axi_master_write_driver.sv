/******************************************************************************
	* DVT CODE TEMPLATE: driver
	* Created by root on Aug 2, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_driver
//
//------------------------------------------------------------------------------


class axi_master_write_driver extends uvm_driver #(axi_frame);

	// The virtual interface used to drive and view HDL signals.
	protected virtual axi_if vif;

	// Configuration object
	axi_config config_obj;

	// Provide implmentations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_master_write_driver)
	 `uvm_field_object(config_obj, UVM_DEFAULT)
 	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the interface
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
			// Propagate the configuration object
			if(!uvm_config_db#(axi_config)::get(this, "", "master_config_obj", config_obj))
				`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

	// run_phase
	virtual task run_phase(uvm_phase phase);
		// The driving should be triggered by an initial reset pulse
		@(negedge vif.sig_reset);
		do
			@(posedge vif.sig_clock);
		while(vif.sig_reset!==1);
		// Start driving here
		get_and_drive();
	endtask : run_phase

	// get_and_drive
	virtual protected task get_and_drive();
		process main; // used by the reset handling mechanism
		forever begin
			// Don't continue with the driving if reset is not high
			do
				@(posedge vif.sig_clock);
			while(vif.sig_reset!==1);
			// Get the next item from the sequencer
			seq_item_port.get_next_item(req);
			$cast(rsp, req.clone());
			rsp.set_id_info(req);
			// Drive current transaction with reset handling mechanism
			fork
				// Drive the transaction
				begin
					main=process::self();
					drive_transfer(rsp);
				end
				// Monitor the reset signal
				begin
					@(negedge vif.sig_reset);
					reset_signals();
					reset_driver();
					// Interrupt current transaction at reset
					if(main) main.kill();
				end
			join_any
			// Send item_done and a response to the sequencer
			seq_item_port.item_done();
			// TODO : If the current transaction was interrupted by a reset you
			// should also set a field in the rsp item to indicate this to the
			// sequence

			seq_item_port.put_response(rsp);
		end
	endtask : get_and_drive

	// reset_signals
	virtual protected task reset_signals();
		// TODO : Reset the signals to their default values
		vif.awaddr = 0;
		vif.awid = 0;
		vif.awcache = 0;
		vif.awburst = 0;
		vif.awlen = 0;
		vif.awlock = 0;
		vif.awprot = 0;
		vif.awqos = 0;
		vif.awvalid = 0;
		vif.wready = 0;
	endtask : reset_signals

	// reset_driver
	virtual protected task reset_driver();
		// TODO : Reset driver specific state variables(e.g. counters,flags,buffers,queues,etc.)
	endtask : reset_driver

	// drive_transfer
	virtual protected task drive_transfer (axi_frame frame);

	endtask : drive_transfer

endclass : uvc_company_uvc_name_driver
