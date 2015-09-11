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

typedef axi_frame axi_frame_queue[$];


class axi_master_write_driver extends uvm_driver #(axi_frame);

	// The virtual interface used to drive and view HDL signals.
	protected virtual axi_if vif;
	axi_frame									rsp_copy;
	axi_frame 									rsp_queue[$];

	// Configuration object
	axi_config config_obj;
	axi_master_write_scheduler2_0 scheduler;
	axi_master_write_main_driver driver;
	axi_master_write_response_driver response;

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
	extern task resetDrivers();
	extern task putResponseToSequencer(input bit[WID_WIDTH - 1 : 0] id );
	extern function true_false_enum findeIndexFromID(input bit[WID_WIDTH-1:0] id_to_check, input axi_frame_queue queue_to_check, ref int index);
	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})

			scheduler = axi_master_write_scheduler2_0::getSchedulerInstance(this);
			driver = axi_master_write_main_driver::getDriverInstance(this);
			response = axi_master_write_response_driver::getDriverInstance(this);


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



 task axi_master_write_driver::getNextBurstFrame();
    forever
	    begin
		    seq_item_port.get_next_item(req);
			$cast(rsp, req.clone());
		    rsp_queue.push_back(req);
		    scheduler.addBurst(rsp);
		    seq_item_port.item_done();
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


 endtask


 task  axi_master_write_driver::startDriver();
	fork
	 	this.driver.main();
		this.response.main();
	join_none
endtask

task axi_master_write_driver::resetDrivers();
	this.scheduler.reset();
	this.driver.reset();
endtask

task axi_master_write_driver::putResponseToSequencer(input bit[WID_WIDTH - 1 : 0] id );
	int index;
	axi_frame to_rsp;
	if(findeIndexFromID(id, rsp_queue, index) == TRUE)
		begin
			seq_item_port.put(rsp_queue[index]);
			rsp_queue.delete(index);
		end
	else
		begin
			`uvm_fatal("AxiMasterDriver", "Got response with non existing ID")
		end

endtask

function true_false_enum axi_master_write_driver::findeIndexFromID(input bit[WID_WIDTH-1:0] id_to_check, input axi_frame_queue queue_to_check, ref int index);
   int i;

	foreach(queue_to_check[i])
		begin
			if(queue_to_check[i].id == id_to_check)
				begin
					index = i;
					return TRUE;
				end
		end
	index = -1;
	return FALSE;
endfunction;


`endif
