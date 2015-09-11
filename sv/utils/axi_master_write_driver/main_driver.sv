`ifndef AXI_MASTER_WRITE_MAIN_DRIVER_SVH
`define AXI_MASTER_WRITE_MAIN_DRIVER_SVH


`define data_before_addr


/**
* Project : AXI UVC
*
* File : main_driver.sv
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
* Description : data bus driver
*
* Classes :	1. axi_master_write_main_driver
*
**/



//-------------------------------------------------------------------------------------
//
// CLASS: axi_master_write_main_driver
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			class axi_master_write_main_driver gets items from scheduler and creates
//			delays between addres and data item.
//			driver can work in corect order ( first addres then data ) or in random
//			order.
//
// API:
//		1. getAddrFrame(output axi_mssg rsp_mssg);
//
//			- get ready address item from driver
//			- returns axi_mssg with status READY if there is ready frame, otherwise NOT_READY
//
//		2. getDataFrame(output axi_mssg rsp_mssg);
//
//			-get ready data item from driver
//			-returns axi_mssg with status READY if there is ready frame, otherwise NOT_READY
//
//		3. extern task pushAddrResponse();
//
//			-this methode should be called when addres item is sent, this infomration is used
//			for correct odrdering packages
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
	axi_master_write_scheduler2_0		scheduler;
	semaphore 							sem;
	static axi_master_write_main_driver	driverInstance;
	axi_mssg							data_mssg;
	axi_mssg 							addr_mssg;
	axi_mssg 							inbox_mssg;
	virtual interface axi_if 			vif;
	event 								address_sent;
	int 								counter;
	axi_master_write_address_driver 	address_driver;
	axi_master_write_data_driver		data_driver;
	true_false_enum						correct_order = TRUE;

	`uvm_component_utils(axi_master_write_main_driver)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new


	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		scheduler = axi_master_write_scheduler2_0::getSchedulerInstance(this);
		address_driver = axi_master_write_address_driver::getDriverInstance(this);
		data_driver = axi_master_write_data_driver::getDriverInstance(this);
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
	extern task pushAddrResponse();

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
		if(data_mssg.frame.last_one == TRUE)
			begin
				$display("LAST DATA SENT NO: %0d, ID: %h", counter, data_mssg.frame.id);
				scheduler.lastPackageSent(data_mssg.frame.id);
				counter++;
			end
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
				   if(correct_order == TRUE)
					   begin
						sem.get(1);
//						addr_inbox_queue.push_back(addr_frame);
					   	addr_ready_queue.push_back(addr_frame); // must be like this
						sem.put(1);
				   		@address_sent;
					   end
				   else
					   begin
						sem.get(1);
					   	addr_inbox_queue.push_back(addr_frame);
				   		sem.put(1);
					   end
			   end
			data_frame = new();
			data_frame = inbox_mssg.frame;
			if(data_frame.delay_data == 0)
				begin
					sem.get(1);
					data_ready_queue.push_back(data_frame);
					sem.put(1);
				end
			else
				begin
					sem.get(1);
					data_inbox_queue.push_back(data_frame);
					sem.put(1);
				end
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

task axi_master_write_main_driver::pushAddrResponse();
	if(correct_order == TRUE)
		begin
			->address_sent;
		end
endtask

`endif

