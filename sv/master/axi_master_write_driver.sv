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
	axi_master_write_scheduler scheduler;
	axi_master_write_vif_driver driver;

	`uvm_component_utils_begin(axi_master_write_driver)
	 `uvm_field_object(config_obj, UVM_DEFAULT)
 	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	extern virtual task getNextBurstFrame();
	extern task startScheduler();
	extern virtual task startDriver();
	extern virtual task resetAll();
	extern virtual protected task reset_signals();
	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the interface
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
			// Propagate the configuration object
			if(!uvm_config_db#(axi_config)::get(this, "", "master_config_obj", config_obj))
				`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})

		scheduler = axi_master_write_scheduler::getSchedulerInstance(this);  // create scheduler and buld id to fetch vif from database
		driver = axi_master_write_vif_driver::getDriverInstance(this); // TODO
	endfunction: build_phase

	// run_phase
	virtual task run_phase(uvm_phase phase);
		// The driving should be triggered by an initial reset pulse
		@(negedge vif.sig_reset);
		do
			@(posedge vif.sig_clock);
		while(vif.sig_reset!==1);

		get_and_drive();
	endtask : run_phase

	// get_and_drive
	virtual protected task get_and_drive();
		process main; // used by the reset handling mechanism
		forever begin
			fork
				this.startDriver();
				this.startScheduler();
				this.getNextBurstFrame();
				this.resetAll();
			join_any
		end
	endtask : get_and_drive

endclass : axi_master_write_driver


// extern functions :

// get next item from sequencer
 task axi_master_write_driver::getNextBurstFrame();
    forever
	    begin
		    seq_item_port.get_next_item(req);
			$cast(rsp, req.clone());
		    scheduler.addBurst(rsp);
//			rsp.set_id_info(req);
//		    seq_item_port.item_done();
//			seq_item_port.put_response(rsp);
	    end
 endtask

//staring scheduler main thread
 task axi_master_write_driver::startScheduler();
     scheduler.main();
 endtask

 task axi_master_write_driver::resetAll();

     @(negedge vif.sig_reset);
		do
			begin
			scheduler.resetAll();

			reset_signals();
			@(posedge vif.sig_clock);
			end
		while(vif.sig_reset!==1);

 endtask


 task axi_master_write_driver::reset_signals();

	vif.awid = 0;
	vif.awaddr = 0;
	vif.awlen = 0;
	vif.awsize = 0;
	vif.awburst = 0;
	vif.awlock = 0;
	vif.awcache = 0;
	vif.awprot = 0;
	vif.awqos = 0;
	vif.awregion = 0;
	vif.awvalid = 0;

	vif.wid = 0;
	vif.wdata = 0;
	vif.wstrb = 0;
	vif.wlast = 0;
	vif.wvalid = 0;

	//wready and awready should slave reset
	vif.bready = 0; // this is answer to slave TODO this maybe should set to 1 becuse than transfer is quicker -- konfigurabilno

 endtask : reset_signals


 task axi_master_write_driver::startDriver();


 endtask

