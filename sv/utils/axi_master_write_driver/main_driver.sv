`ifndef AXI_MASTER_WRITE_MAIN_DRIVER_SVH
`define AXI_MASTER_WRITE_MAIN_DRIVER_SVH


`define data_before_addr
//------------------------------------------------------------------------------
//
// CLASS: axi_master_write_main_driver
//
//------------------------------------------------------------------------------



//this class is bridge for scheduler and separate vif drivers ( data vif driver and addess vid driver)
//usage: this struct will get all redy frames from scheduler and do specific delay for packages;

class axi_master_write_main_driver extends uvm_component;

	axi_single_frame					addr_inbox_queue[$];
	axi_single_frame					data_inbox_queue[$];
	axi_single_frame					addr_ready_queue[$];
	axi_single_frame 					data_ready_queue[$];
	axi_single_frame 					addr_frame;
	axi_single_frame 					data_frame;
	axi_master_write_scheduler			scheduler;
	semaphore 							sem;
	static axi_master_write_main_driver	driverInstance;
	axi_mssg							data_mssg;
	axi_mssg 							addr_mssg;
	axi_mssg 							inbox_mssg;
	virtual interface axi_if 			vif;

	axi_master_write_address_driver 	address_driver; // FIXME
	axi_master_write_data_driver		data_driver;
	true_false_enum						correct_order = TRUE;

	`uvm_component_utils(axi_master_write_main_driver)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);

	endfunction : new

	// build_phase
	function void build();
		scheduler = axi_master_write_scheduler::getSchedulerInstance(this);
		address_driver = axi_master_write_address_driver::getDriverInstance(this); // FIXME
		data_driver = axi_master_write_data_driver::getDriverInstance(this);
		address_driver.build(); // FIXME
		data_driver.build();
		sem = new(10);
	endfunction

	extern task  getAddrFrame(output axi_mssg rsp_mssg);
	extern task  getDataFrame(output axi_mssg rsp_mssg);
	extern static function axi_master_write_main_driver getDriverInstance(input uvm_component parent);
	extern task mainMainDriver(input int clocks);
	extern task main();
	extern task getFramesFromScheduler();
	extern task decrementDelay();
	extern task reset();

	extern function void setCorrectAddressDataOrder(true_false_enum correct);

endclass : axi_master_write_main_driver


// singleton class -- to create or get instace call this static function
function axi_master_write_main_driver axi_master_write_main_driver::getDriverInstance(input uvm_component parent);
    if(driverInstance == null)
	    begin
	    driverInstance = new("Write driver main", parent);
		$display("Created  Driver Core");
	    end
	return driverInstance;
endfunction

// get address frame - it should be called from virtual interface address bus driver
// it returns axi_mssg with frame and status:
// 		if address queue is empty axi_mssg status will be NOT_READY and null as frame
task axi_master_write_main_driver::getAddrFrame(output axi_mssg rsp_mssg);
	addr_mssg = new();
	sem.get(1);
	if(addr_ready_queue.size() > 0 )
		begin
		addr_mssg.frame = addr_ready_queue.pop_front();
		addr_mssg.state = READY;
		end
	else
		begin
		addr_mssg.frame = null;
		addr_mssg.state = NOT_READY;
		end;
	sem.put(1);
	rsp_mssg = addr_mssg;
endtask

// get datat frame - it shoul be called from virtual interface data bus driver
// it returns axi_mssg with frame and status:
// 		if data queue is empty axi_mssg status will be NOT_READY and null as frame
task  axi_master_write_main_driver::getDataFrame(output axi_mssg rsp_mssg);
	data_mssg = new();
	sem.get(1);
	if(data_ready_queue.size() > 0 )
		begin
		data_mssg.frame = data_ready_queue.pop_front();
		data_mssg.state = READY;
//		$display("DRIVER MASTER MAIN: Sendding full data");
		end
	else
		begin
		data_mssg.frame = null;
		data_mssg.state = NOT_READY;
		end;
	sem.put(1);
	rsp_mssg = data_mssg;
endtask

task axi_master_write_main_driver::main();
    fork
	    this.data_driver.main();
	    this.address_driver.main();
//	    this.address_driver.testClock();
    join
endtask

task axi_master_write_main_driver::mainMainDriver(input int clocks);
	repeat(clocks)
		begin
//			$display("                                        MAIN DRIVER CLOCK ");
			this.getFramesFromScheduler();
			this.decrementDelay();
		end
endtask


task axi_master_write_main_driver::getFramesFromScheduler();
   forever
	   begin
		   scheduler.getFrameForDrivingVif(inbox_mssg);
		   if(inbox_mssg.state == QUEUE_EMPTY)
			   return;
		   if (inbox_mssg.frame.first_one == TRUE)
			   begin
				   addr_frame = new();
				   addr_frame = inbox_mssg.frame;
				   sem.get(1);
				   if(correct_order == TRUE)
					   addr_ready_queue.push_back(addr_frame);
				   else
					   addr_inbox_queue.push_back(addr_frame);
				   sem.put(1);
			   end
			data_frame = new();
			data_frame = inbox_mssg.frame;
			sem.get(1);
			data_inbox_queue.push_back(data_frame);
			sem.put(1);
	   end
endtask


task axi_master_write_main_driver::decrementDelay();
	sem.get(1);
	if(addr_inbox_queue.size() > 0)
		begin
			if(addr_inbox_queue[0].delay_addr == 0)
				begin
					addr_ready_queue.push_back(addr_inbox_queue.pop_front);
				end
			else
				begin
					addr_inbox_queue[0].delay_addr--;
				end
		end
	if(data_inbox_queue.size() > 0)
		begin
			if(data_inbox_queue[0].first_one == FALSE || data_inbox_queue[0].delay_data == 0 )
				begin
//					$display("adding frame to ready data queue");
					data_ready_queue.push_back(data_inbox_queue.pop_front());
				end
			else
				begin
					data_inbox_queue[0].delay_data--;
				end
		end
		sem.put(1);
endtask


task axi_master_write_main_driver::reset();
   	sem.get(1);
	addr_inbox_queue.delete();
	addr_ready_queue.delete();
	data_inbox_queue.delete();
	data_ready_queue.delete();
	sem.put(1);
endtask

function void axi_master_write_main_driver::setCorrectAddressDataOrder(input true_false_enum correct);
 		correct_order = correct;
	`uvm_info("axi_master_write_main_driver","correct_order == TRUE", UVM_LOW);
endfunction

`endif

