`ifndef AXI_MASTER_WRITE_MAIN_DRIVER_SVH
`define AXI_MASTER_WRITE_MAIN_DRIVER_SVH

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

	axi_master_write_address_driver 	address_driver;
	axi_master_write_data_driver		data_driver;

	`uvm_component_utils(axi_master_write_main_driver)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		scheduler = axi_master_write_scheduler::getSchedulerInstance(this);
		address_driver = axi_master_write_address_driver::getDriverInstance(this);
		data_driver = axi_master_write_data_driver::getDriverInstance(this);
	endfunction : new

	// build_phase
	function void build();

		address_driver.build();
		data_driver.build();

		sem = new(1);
		inbox_mssg = new();

		fork
			address_driver.main();
			data_driver.main();
		join_none;

	endfunction

	extern function axi_mssg getAddrFrame();
	extern function axi_mssg getDataFrame();
	extern static function axi_master_write_main_driver getDriverInstance(input uvm_component parent);
	extern function void mainMainDriver(input int clocks);
	extern task main();
	extern function void getFramesFromScheduler();
	extern function void decrementDelay();
	extern function void reset();

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
function axi_mssg axi_master_write_main_driver::getAddrFrame();
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
endfunction

// get datat frame - it shoul be called from virtual interface data bus driver
// it returns axi_mssg with frame and status:
// 		if data queue is empty axi_mssg status will be NOT_READY and null as frame
function axi_mssg axi_master_write_main_driver::getDataFrame();
	data_mssg = new();
	sem.get(1);
	if(data_ready_queue.size() > 0 )
		begin
		data_mssg.frame = data_ready_queue.pop_front();
		data_mssg.state = READY;
		end
	else
		begin
		data_mssg.frame = null;
		data_mssg.state = NOT_READY;
		end;
	sem.put(1);
endfunction

task axi_master_write_main_driver::main();
    fork
//	    this.mainMainDriver();
	    this.data_driver.main();
	    this.address_driver.main();
    join
endtask

function void axi_master_write_main_driver::mainMainDriver(input int clocks);
	repeat(clocks)
		begin
			this.getFramesFromScheduler();
			this.decrementDelay();
		end
endfunction


function void axi_master_write_main_driver::getFramesFromScheduler();
   forever
	   begin
		   inbox_mssg = scheduler.getFrameForDrivingVif();
		   if(inbox_mssg.state == QUEUE_EMPTY)
			   return;
		   if (inbox_mssg.frame.first_one == TRUE)
			   begin
				   addr_frame = new();
				   addr_frame = inbox_mssg.frame;
				   sem.get(1);
				   addr_inbox_queue.push_back(addr_frame);
				   sem.put(1);
			   end
			data_frame = new();
			data_frame = inbox_mssg.frame;
			sem.get(1);
			data_inbox_queue.push_back(data_frame);
			sem.put(1);
	   end
endfunction


function void axi_master_write_main_driver::decrementDelay();
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
					data_ready_queue.push_back(data_inbox_queue.pop_front());
				end
			else
				begin
					data_inbox_queue[0].delay_data--;
				end
		end
		sem.put(1);
endfunction


function void axi_master_write_main_driver::reset();
   	sem.get(1);
	addr_inbox_queue.delete();
	addr_ready_queue.delete();
	data_inbox_queue.delete();
	data_ready_queue.delete();
	sem.put(1);
endfunction

`endif

