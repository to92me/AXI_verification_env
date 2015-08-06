/******************************************************************************
	* DVT CODE TEMPLATE: driver
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_read_driver
//
//------------------------------------------------------------------------------

class axi_slave_read_driver extends uvm_driver #(axi_frame);

	// The virtual interface used to drive and view HDL signals.
	protected virtual axi_if vif;

	// Configuration object
	axi_slave_config config_obj;

	// Provide implmentations of virtual methods such as get_type_name and create
	`uvm_component_utils(axi_slave_read_driver)

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
			if(!uvm_config_db#(axi_slave_config)::get(this, "", "config_obj", config_obj))
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
		/*process main; // used by the reset handling mechanism
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
		end*/
		fork
			get_from_seq();
			reset();
			get_next_item();
			drive_next_item();
		join
	endtask : get_and_drive
	
	virtual protected task get_from_seq();
		forever begin
			seq_item_port.get_next_item(req);
			$cast(rsp, req.clone());
			rsp.set_id_info(req);
			// TODO: send to arbitration
			seq_item_port.item_done();
			seq_item_port.put_response(rsp);
		end
	end task : get_from_seq

	virtual protected task reset();
		forever begin
			@(negedge vif.sig_reset)
			`uvm_info(get_type_name(), "Reset", UVM_MEDIUM)

			// reset signals
			vif.rid <= {ID_WIDTH {1'b0}};
			vif.rdata <= {DATA_WIDTH {1'bz}};
			vif.rresp <= 2'b00;
			vif.rlast <= 1'b0;
			//vif.ruser
			vif.rvalid <= 1'b0;
			vif.arready <= 1'b1;

			// TODO: reset queues
			
			// TODO: reset sequence

		end
	endtask : reset

/*
	// reset_signals
	virtual protected task reset_signals();
		forever begin
			@(negedge vif.sig_reset)
			`uvm_info(get_type_name(), "Reset signals", UVM_MEDIUM)
			vif.rid <= {ID_WIDTH {1'b0}};
			vif.rdata <= {DATA_WIDTH {1'bz}};
			vif.rresp <= 2'b00;
			vif.rlast <= 1'b0;
			//vif.ruser
			vif.rvalid <= 1'b0;
			vif.arready <= 1'b1;
		end
	endtask : reset_signals

	// reset_driver
	virtual protected task reset_driver();
		// TODO : Reset driver specific state variables(e.g. counters,flags,buffers,queues,etc.)
	endtask : reset_driver

	// drive_transfer
	virtual protected task drive_transfer (axi_frame trans);
		// TODO : Drive the transfer

	endtask : drive_transfer
*/
endclass : axi_slave_read_driver
