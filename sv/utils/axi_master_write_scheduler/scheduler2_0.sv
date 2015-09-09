`ifndef AXI_MASTER_WRITE_SCHEDULER2_0_SVH
`define AXI_MASTER_WRITE_SCHEDULER2_0_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------
typedef axi_master_write_scheduler_package2_0	package_queue[$];


class axi_master_write_scheduler2_0 extends uvm_component;
	static axi_master_write_scheduler2_0	scheduler_instance;
	axi_master_write_driver					top_driver;
	axi_write_conf							config_obj;
	semaphore 								sem;

	//queues for manageing bursts
	axi_master_write_scheduler_package2_0	active_queue[$];
	axi_master_write_scheduler_package2_0	inactive_queue[$];
	axi_master_write_scheduler_package2_0	duplicate_ID_queue[$];
	axi_master_write_scheduler_package2_0	waiting_for_RSP_queue[$];
	axi_master_write_scheduler_package2_0	waiting_to_send_all_queue[$];

	axi_single_frame 						next_frame_for_sending[$];

	bit[ID_WIDTH -1 : 0]					empty_queue_id_queue[$];
	bit[ID_WIDTH -1 : 0]					all_data_sent_queue[$];
	bit[ID_WIDTH -1 : 0]					delet_queue_id_queue[$];
	bit[ID_WIDTH -1 : 0]					check_for_duplicate_id_queue[$];
	axi_slave_response						recieved_response[$];
	axi_frame								add_burst_frame_queue[$];
	//burst_options
	int 									burst_deepth_mode;
	int										burst_deepth = 5;
	int 									burst_active = 0;

	`uvm_component_utils_begin(axi_master_write_scheduler2_0)
		`uvm_field_int(burst_deepth_mode, UVM_DEFAULT)
		`uvm_field_int(burst_deepth, UVM_DEFAULT)
 	`uvm_component_utils_end

// constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		sem = new(1);
	endfunction : new

//get singleton instance
	static function axi_master_write_scheduler2_0 getSchedulerInstance(input uvm_component parent);
		if(scheduler_instance == null)
			begin
				$display("Creating Sceduler 2.0");
				scheduler_instance = new("MasterWriteScheduler", parent);
			end
		return scheduler_instance;
	endfunction

//build phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(axi_write_conf)::get(this, "", "uvc_write_config", config_obj))
		 `uvm_fatal("NO UVC_CONFIG",{"uvc_write config must be set for ",get_full_name(),".uvc_write_config"})
	endfunction : build_phase

	extern function void setTopDriverInstance(input axi_master_write_driver top_driver_instance);

// MAIN
	extern task main(input int clocks);

//	API
	extern task addBurst(axi_frame frame);
	extern task getFrameForDrivingVif(output axi_mssg mssg);
	extern task putResponseFromSlave(input axi_slave_response rsp);
	extern task lastPackageSent(input  bit[ID_WIDTH-1 : 0] sent);


// LOCAL FUNCTIONS
	extern local task checkUniqueID(input bit[ID_WIDTH-1 : 0] id_to_check, package_queue queue_to_check, output true_false_enum existing_id);
	extern local task checkForDone();
	extern local task searchReadyFrame();
	extern local task delayCalculator();
	extern local task responseLatnesCalculator();
	extern local task manageBurstStatus();
	extern local task addBurstPackage(input axi_frame frame);

	extern local task findeIndexFromID(input bit[ID_WIDTH-1 : 0] id_to_check, package_queue queue_to_check, output index);

endclass : axi_master_write_scheduler2_0




task axi_master_write_scheduler2_0::main(input int clocks);
   repeat(clocks)
	   begin
	   end
endtask

task axi_master_write_scheduler2_0::addBurst(input axi_frame frame);
	sem.get(1);
    add_burst_frame_queue.push_back(frame);
	sem.put(1);
endtask


task axi_master_write_scheduler2_0::addBurstPackage(input axi_frame frame);
	true_false_enum  						unique_id1;
	true_false_enum  						unique_id2;

    axi_master_write_scheduler_package2_0 	new_burst;
	new_burst = new("SchedulerPackage",config_obj);

	new_burst.addBurst(frame);

	checkUniqueID(frame.id, active_queue,unique_id1);
	checkUniqueID(frame.id, inactive_queue, unique_id2);

	// if this is duplicate ID then store it to corresponding queue
	if(unique_id1 == FALSE || unique_id2 == FALSE)
		begin
			duplicate_ID_queue.push_back(new_burst);
		end

	if(burst_active < burst_deepth)
		begin
			burst_active++;
		// if active queue is empyt
			if(active_queue.size() == 0)
				begin
					new_burst.setLock_state(QUEUE_UNLOCKED);
					active_queue.push_back(new_burst);
				end
			if(active_queue[active_queue.size()-1].getFirst_status == FIRST_SENT)
					begin
						new_burst.setLock_state(QUEUE_UNLOCKED);
					end
				else
					begin
						new_burst.setLock_state(QUEUE_UNLOCKED);
					end
			active_queue.push_back(new_burst);
		end
	else
		begin
			inactive_queue.push_back(new_burst);
		end
endtask


task axi_master_write_scheduler2_0::checkUniqueID(input bit[ID_WIDTH-1:0] id_to_check, input package_queue queue_to_check, output true_false_enum existing_id);
    int i;
	sem.get(1);
    foreach(queue_to_check[i])
	    begin
		    if(queue_to_check[i].getID == id_to_check)
			    begin
			    	existing_id = TRUE;
				    sem.put(1);
				    return;
			    end
	    end
	 sem.put(1);
	 existing_id = FALSE;
	 return;
endtask


task axi_master_write_scheduler2_0::searchReadyFrame();
	axi_mssg rsp_mssg;
   int i;
	foreach(active_queue[i])
		begin
		 	active_queue[i].getNextSingleFrame(rsp_mssg);
			if(rsp_mssg.state == READY)
				begin
					sem.get(1);
						next_frame_for_sending.push_back(rsp_mssg.frame);
					sem.put(1);

					if(active_queue[i+1] != null)
						begin
							active_queue[i+1].setLock_state(QUEUE_UNLOCKED);
						end
				end
			else if(rsp_mssg.state == QUEUE_EMPTY)
				begin
					empty_queue_id_queue.push_back(rsp_mssg.frame.id);
				end
		end
endtask

task axi_master_write_scheduler2_0::delayCalculator();
	int i;
    foreach(active_queue[i])
	    begin
		    active_queue[i].decrementDelay();
	    end
endtask

task axi_master_write_scheduler2_0::lastPackageSent(input bit[ID_WIDTH-1:0] sent_id);
	int 				i;
	true_false_enum 	found;
   foreach(waiting_to_send_all_queue[i])
	   begin
		   if(waiting_to_send_all_queue[i].getID() == sent_id)
			   begin
				   found = TRUE;
				   all_data_sent_queue.push_back(sent_id);
			   end
	   end

	   if(found == FALSE)
		   begin
			   `uvm_warning("Scheduler2_0","Did not found requested package");
		   end

endtask


task axi_master_write_scheduler2_0::checkForDone();
    if(active_queue.size() == 0 &&
	    inactive_queue.size() == 0 &&
	    waiting_to_send_all_queue.size == 0 &&
	    waiting_for_RSP_queue.size() == 0 &&
	    duplicate_ID_queue.size() == 0)
	    begin

		    top_driver.putResponseToSequencer();

	    end

endtask

task axi_master_write_scheduler2_0::responseLatnesCalculator();
	int i;
  	foreach(waiting_for_RSP_queue[i])
	  	begin
		  	if(waiting_for_RSP_queue[i].decrementResponseLatenesCounter() == TRUE)
			  	begin
			  		delet_queue_id_queue.push_back(waiting_for_RSP_queue[i].getID());
			  	end
	  	end
endtask


task axi_master_write_scheduler2_0::manageBurstStatus();
	int index;
	bit[ID_WIDTH - 1 : 0]	id;
	// add new burst
	sem.get(1);
	while(add_burst_frame_queue.size() != 0)
		begin
			addBurstPackage(add_burst_frame_queue.pop_front());
		end
	sem.put();

	while(empty_queue_id_queue.size() != 0)
		begin
			id = empty_queue_id_queue.pop_front();
			findeIndexFromID(id,active_queue, index);
			waiting_to_send_all_queue.push_back(active_queue[index]);
			active_queue.delete(index);
			check_for_duplicate_id_queue.push_back(id);
			if(burst_deepth_mode == 1)
				begin
					burst_active--;
				end
		end

	// TU SAM STAO
endtask



task axi_master_write_scheduler2_0::findeIndexFromID(input bit[ID_WIDTH-1:0] id_to_check, input package_queue queue_to_check, output index);
   int i;
	foreach(queue_to_check[i])
		begin
			if(queue_to_check[i].getID() == id_to_check)
				begin
					index = i;
					return;
				end
		end
	index = -1;

endtask


// ==================================== INSTANCES ====================================================

function void axi_master_write_scheduler2_0::setTopDriverInstance(input axi_master_write_driver top_driver_instance);
    this.top_driver = top_driver_instance;
endfunction

// ================================ API IMPLEMENTATION ===============================================


task axi_master_write_scheduler2_0::putResponseFromSlave(input axi_slave_response rsp);
   	sem.get(1);
	recieved_response.push_back(rsp);
	sem.put(1);
endtask

task axi_master_write_scheduler2_0::getFrameForDrivingVif(output axi_mssg mssg);
	axi_mssg send;
	int tmp;
	send = new();

	sem.get(1);
	tmp = next_frame_for_sending.size();
	sem.put(1);

	if(tmp > 0)
		begin
			sem.get(1);
			send.frame  = next_frame_for_sending.pop_back();
	    	send.state = READY;
			sem.put(1);
		end
	else
		begin
			sem.get(1);
			send.state = QUEUE_EMPTY;
			send.frame = null;
		    sem.put(1);
		end

		mssg = send;

endtask

`endif
