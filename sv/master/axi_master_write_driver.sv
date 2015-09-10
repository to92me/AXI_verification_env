`ifndef AXI_MASTER_DRIVER_SVH
`define AXI_MASTER_DRIVER_SVH

/**
* Project : AXI UVC
*
* File : axi_master_write_driver.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Tomislav Tumbas
*
* E-Mail : tomislav.tumbas@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : master write main driver
*
* Classes :	1. axi_master_write_driver
*
**/


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
	axi_master_write_scheduler2_0 scheduler;  // FIXME scheduler
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
	extern task resetDrivers();
	extern task putResponseToSequencer();
	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})

			scheduler = axi_master_write_scheduler2_0::getSchedulerInstance(this);
			driver = axi_master_write_main_driver::getDriverInstance(this);
			response = axi_master_write_response_driver::getDriverInstance(this);

//			driver.build();
//			response.build();
			scheduler.setTopDriverInstance(this);
	endfunction: build_phase

	// run_phase
	virtual task run_phase(uvm_phase phase);
		// The driving should be triggered by an initial reset pulse
//		@(negedge vif.sig_reset);
//		do
//			@(posedge vif.sig_clock);
//		while(vif.sig_reset!==1);

		get_and_drive();
	endtask : run_phase

	virtual protected task get_and_drive();
//		process main; // used by the reset handling mechanism
		forever begin
			fork
				this.getNextBurstFrame();
				this.startDriver();
				this.startScheduler();
				this.resetAll();
			join
		end
	endtask : get_and_drive

endclass : axi_master_write_driver


// get next item from sequencer
 task axi_master_write_driver::getNextBurstFrame();
    forever
	    begin
		     $display("adding new item --------------------------------------------------------------------------------------------------------");
		    seq_item_port.get_next_item(req);
			$cast(rsp, req.clone());
//		    rsp.set_id_info(req);
		    scheduler.addBurst(rsp);
		    seq_item_port.item_done();
		    $display("adding new item DONE--------------------------------------------------------------------------------------------------------");
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

//     scheduler.main();
 endtask


 task  axi_master_write_driver::startDriver();
	fork
	 	this.driver.main();
		this.response.main();
	join_none
	$display("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
endtask

task axi_master_write_driver::resetDrivers();
	this.scheduler.reset();
	this.driver.reset();
endtask

task axi_master_write_driver::putResponseToSequencer();
	seq_item_port.put_response(rsp);
endtask

`endif
