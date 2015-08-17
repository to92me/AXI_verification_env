`ifndef AXI_MASTER_DRIVER_SVH
`define AXI_MASTER_DRIVER_SVH

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
	axi_master_write_main_driver driver;
	axi_master_write_response_driver response;

	`uvm_component_utils_begin(axi_master_write_driver)
	 `uvm_field_object(config_obj, UVM_DEFAULT)
 	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		  // create scheduler and buld id to fetch vif from database
	endfunction : new

	extern virtual task getNextBurstFrame();
	extern task startScheduler();
	extern virtual task startDriver();
	extern virtual task resetAll();
	extern function void resetDrivers();
	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
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

	virtual protected task get_and_drive();
		process main; // used by the reset handling mechanism
		forever begin
			fork
				this.startDriver();
				this.startScheduler();
				this.getNextBurstFrame();
				this.resetAll();
			join
		end
	endtask : get_and_drive

endclass : axi_master_write_driver


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

 task axi_master_write_driver::resetAll();

     @(negedge vif.sig_reset);
		do
			begin
			resetDrivers();
			@(posedge vif.sig_clock);
			end
		while(vif.sig_reset!==1);

 endtask

task axi_master_write_driver::startScheduler();
		scheduler = axi_master_write_scheduler::getSchedulerInstance(this);
//     scheduler.main();
 endtask


 task  axi_master_write_driver::startDriver();
		driver = axi_master_write_main_driver::getDriverInstance(this);
		response = axi_master_write_response_driver::getDriverInstance(this);
		driver.build();
		response.build();
//	 	this.driver.main();
//		this.response.main();
 endtask

function void axi_master_write_driver::resetDrivers();
	this.scheduler.resetAll();
	this.driver.reset();
endfunction

`endif
