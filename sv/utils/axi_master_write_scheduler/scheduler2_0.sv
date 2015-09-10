`ifndef AXI_MASTER_WRITE_SCHEDULER2_0_SVH
`define AXI_MASTER_WRITE_SCHEDULER2_0_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------
// burst deepth mode

// mode 1 - wait to recieve responde
// mode 2  - dont wait for respond

typedef axi_master_write_scheduler_package2_0	package_queue[$];


class axi_master_write_scheduler2_0 extends uvm_component;
	static axi_master_write_scheduler2_0	scheduler_instance;
	axi_master_write_driver					top_driver;
	axi_write_conf							config_obj;
	semaphore 								sem;
	int 									response_counter = 0;

	//queues for manageing bursts lives
	axi_master_write_scheduler_package2_0	active_queue[$];
	axi_master_write_scheduler_package2_0	inactive_queue[$];
	axi_master_write_scheduler_package2_0	duplicate_ID_queue[$];
	axi_master_write_scheduler_package2_0	waiting_for_RSP_queue[$];
	axi_master_write_scheduler_package2_0	waiting_to_send_all_queue[$];

	//main driver gets packages from here
	axi_single_frame 						next_frame_for_sending[$];

	//queues for manageing burst statuses
	bit[ID_WIDTH -1 : 0]					empty_queue_id_queue[$]; // when queue is empyt here are stored his ID-s
	bit[ID_WIDTH -1 : 0]					rsp_latenes_exipired_id_queue[$]; // if response did not come after some time
	bit[ID_WIDTH -1 : 0]					recieved_all_send_mssg_id_queue[$]; // when queue is deleted check for duplocates
	bit[ID_WIDTH -1 : 0]					check_for_Id_duplicates_id_queue[$];

	axi_slave_response						recieved_response[$]; // this are recieved responses
	axi_frame								add_burst_frame_queue[$]; // waiting to add to some burst
	//burst_options
	burst_deepth_mode_enum 					burst_deepth_mode = MODE_1;
	int										burst_deepth = 5;
	int 									burst_active = 0;

	`uvm_component_utils_begin(axi_master_write_scheduler2_0)
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
	extern task lastPackageSent(input bit[ID_WIDTH-1:0] sent_id);
	extern task reset();


// LOCAL METHODES
	extern local task checkUniqueID(input bit[ID_WIDTH-1 : 0] id_to_check, package_queue queue_to_check, output true_false_enum existing_id);
	extern local task checkForDone();
	extern local task searchReadyFrame();
	extern local task delayCalculator();
	extern local task responseLatnesCalculator();
	extern local task manageBurstStatus();
	extern local task addBurstPackage(input axi_frame frame);

	extern local function true_false_enum findeIndexFromID(input bit[ID_WIDTH-1 : 0] id_to_check, package_queue queue_to_check, ref int index);

// PUT RESPONSE METHODES
	extern local task gotOkayResponse(input bit[ID_WIDTH-1 : 0] rsp_id, int index, input int where_is_burst_found);
	extern local task gotExOkayResponse(input bit[ID_WIDTH-1 : 0] rsp_id, int index, input int where_is_burst_found);
	extern local task gotSlaveErrorResponse(input bit[ID_WIDTH-1 : 0] rsp_id, int index, input int where_is_burst_found);
	extern local task gotDecErrorResponse(input bit[ID_WIDTH-1 : 0] rsp_id, int index, input int where_is_burst_found);

// TESTING
	extern local function void PrintActive();
endclass




task axi_master_write_scheduler2_0::main(input int clocks);
   repeat(clocks)
	   begin
//		   $display("clock");
		   this.searchReadyFrame();
		   this.delayCalculator();
		   this.responseLatnesCalculator();
		   this.manageBurstStatus();
		   this.checkForDone();
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
	if(unique_id1 == TRUE || unique_id2 == TRUE)
		begin
			duplicate_ID_queue.push_back(new_burst);
			return;
		end

	if(burst_active < burst_deepth)
		begin
			burst_active++;
		// if active queue is empyt
			if(active_queue.size() == 0)
				begin
					new_burst.setLock_state(QUEUE_UNLOCKED);
				end
			else if(active_queue[active_queue.size()-1].getFirst_status == FIRST_SENT)
					begin
						new_burst.setLock_state(QUEUE_UNLOCKED);
					end
			else
					begin
						new_burst.setLock_state(QUEUE_LOCKED);
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
    foreach(queue_to_check[i])
	    begin
		    if(queue_to_check[i].getID == id_to_check)
			    begin
			    	existing_id = TRUE;

				    return;
			    end
	    end
	 existing_id = FALSE;
	 return;
endtask


task axi_master_write_scheduler2_0::searchReadyFrame();
	axi_mssg rsp_mssg;
	int id;
	int i;
	rsp_mssg = new();
	foreach(active_queue[i])
		begin
		 	active_queue[i].getNextSingleFrame(rsp_mssg);
			if(rsp_mssg.state == READY)
				begin
//					$display("Frmame");
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
					int index;
					id = rsp_mssg.frame.id;
					PrintActive();
					$display("ID : %h", id);
					findeIndexFromID(id, active_queue, index);
					$display("returned index: %0d", index);
					PrintActive();
					$display("id: %h len: %0d",active_queue[index].getID(), active_queue[index].single_frame_queue.size());
					empty_queue_id_queue.push_back(id);
					PrintActive();
				if(active_queue[index].single_frame_queue.size() != 0)
					begin
						`uvm_fatal("Fatal","-1")
					end
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
	sem.get(1);
	recieved_all_send_mssg_id_queue.push_back(sent_id);
	sem.put(1);
endtask


task axi_master_write_scheduler2_0::checkForDone();
//	$display("CHECK FOR DONE : active_queue: %0d, inactive_queue: %0d, waiting_to_send_all_queue: %0d,\
//				waiting_for_RSP_queue: %0d,duplicate_ID_queue: %0d",active_queue.size(),inactive_queue.size(),
//				waiting_to_send_all_queue.size(),  waiting_for_RSP_queue.size(), duplicate_ID_queue.size());

    if(active_queue.size() == 0 &&
	    inactive_queue.size() == 0 &&
	    waiting_to_send_all_queue.size() == 0 &&
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
			  		rsp_latenes_exipired_id_queue.push_back(waiting_for_RSP_queue[i].getID());
			  	end
	  	end
endtask

// ================================== MANAGE BURST LIFE =====================================
//
// LIFE OF BUST SCHEME
//
//  			 ----------------------------------------------------------------------------
// 				|    active     | waiting_to_send 	| wating_rsp 	| delete and put respose |
//   -----------|---------------|------------------------------------------------------------
// 	|add new	| inactive 		|
// 	 -----------|---------------|
// 				| duplicate ID 	|
// 				 ---------------
//
task axi_master_write_scheduler2_0::manageBurstStatus();
	int 					index;
	bit[ID_WIDTH - 1 : 0]	id;


//  			 ----------------------------------------------------------------------------
// 			 	|    	      	| 					| 			 	|						 |
//   -----------|---------------|------------------------------------------------------------
// 	|add new	| 		 		|
// 	 -----------|---------------|
// 				| 			 	|
// 				 ---------------
//
//	sem.get(1);
	while(add_burst_frame_queue.size() != 0)
		begin
			sem.get(1);
			addBurstPackage(add_burst_frame_queue.pop_front());
			sem.put(1);
		end
//	sem.put(1);


//  ACTIVE QUEUE IS EMPYT ->
//
// 				 ---------------------------------------------------------------------------
// 			 	|    current    ->waiting to send all| 			 	|						|
//   -----------|---------------|-----------------------------------------------------------
// 	| done 		| 		 		|
// 	 -----------|---------------|
// 				| 			 	|
// 				 ---------------
//
	while(empty_queue_id_queue.size() != 0)
		begin
			id = empty_queue_id_queue.pop_front();
//			$display("Recieved empty Queue item ID: %0h",id );
			if(findeIndexFromID(id,active_queue, index) == FALSE)
				begin
					`uvm_fatal("Fatal","0")
				end
			if(active_queue[index].single_frame_queue.size() != 0)
				begin
					`uvm_fatal("Fatal","1")
				end
			waiting_to_send_all_queue.push_back(active_queue[index]);
			active_queue.delete(index);
			// if burst mode2 =  dont wait to recieve rsp just add new queue
			if(burst_deepth_mode == MODE_2)
				begin
				//	burst_active--;
				end
		end

//GOT ALL_SENT_MSSG -> WAIT FOR RSP
//
//               ---------------------------------------------------------------------------
//   			|    done       |waiting to send all->waitin_to_rsp|						|
//   -----------|---------------|-----------------------------------------------------------
// 	|  done 	| 		 		|
// 	 -----------|---------------|
// 				| 			 	|
// 				 ---------------
//

	while(recieved_all_send_mssg_id_queue.size() !=0)
		begin
			sem.get(1);
			id = recieved_all_send_mssg_id_queue.pop_front();
			sem.put(1);
			$display("Recieved Sent Last item ID: %0d",id );
			if(findeIndexFromID(id,waiting_to_send_all_queue, index) == FALSE)
				begin
					`uvm_fatal("MasterWriteScheduler","waiting to send all packages ")
				end
			waiting_for_RSP_queue.push_back(waiting_to_send_all_queue[index]);
			waiting_to_send_all_queue.delete(index);
		end


// GOT RPS -> DELET QUEUE ( check duplicate and decrement active burst )
//																got rsp
//															 ------------------>
//															|					|
//               ---------------------------------------------------------------------------
//   			|    done       |    done 				|waitin_to_rsp -> delete			|
//   -----------|---------------|-----------------------------------------------------------
// 	|  done 	| 		 		|
// 	 -----------|---------------|
// 				| 			 	|
// 				 ---------------
//
	while(recieved_response.size() != 0)
		begin
			int 				where_is_found;
			true_false_enum		found;

			response_enum		rsp_info;
			axi_slave_response 	rsp;
			rsp = recieved_response.pop_front();
			id = rsp.getID();
			rsp_info = rsp.getRsp();

			$display("MAIN RECIEVED RSP NO: %0d, ID %h", response_counter, id);

			if( findeIndexFromID(id, waiting_for_RSP_queue, index) == TRUE)
				begin

					found = TRUE;
					where_is_found = 1;
				end
			else if( findeIndexFromID(id, waiting_to_send_all_queue, index) == TRUE)
				begin
					//`uvm_fatal("oD ", "2")
					found = TRUE;
					where_is_found = 2;
				end

			else if(findeIndexFromID(id, active_queue, index) == TRUE)
				begin
					`uvm_fatal("oD ", "3")
					found = TRUE;
					where_is_found = 3;
				end
			if(found == TRUE)
				begin
					$display(" ");
					$display("MAIN RECIEVED RSP NO: %0d, ID %h", response_counter, id);
					$display(" ");
					response_counter++;
					// id mode = 1 :
					if(burst_deepth_mode == MODE_1)
						begin
							burst_active--;
						end

					//push ID to check for duplicates

					check_for_Id_duplicates_id_queue.push_back(id);


					`uvm_info(get_name(),$sformatf("Recieved Valid ID Response: %h, option: %0d", id, where_is_found), UVM_INFO)


					$display("CHECK FOR DONE : active_queue: %0d, inactive_queue: %0d, waiting_to_send_all_queue: %0d,\
					waiting_for_RSP_queue: %0d,duplicate_ID_queue: %0d",active_queue.size(),inactive_queue.size(),
					waiting_to_send_all_queue.size(),  waiting_for_RSP_queue.size(), duplicate_ID_queue.size());


					case(rsp_info)
						OKAY:
						begin
							gotOkayResponse(id, index, where_is_found);
						end

						EXOKAY:
						begin
							gotExOkayResponse(id, index, where_is_found);
						end

						SLVERR:
						begin
							gotSlaveErrorResponse(id, index, where_is_found);
						end

						DECERR:
						begin
							gotDecErrorResponse(id, index, where_is_found);
						end

					endcase
				end
			else
				begin
					$display("MasterWriteScheduler [ERROR] Error in recieved response from NON EXISTING burst id: %h",id);
					//`uvm_warning("MasterWriteScheduler [ERROR]: ", $sformat("Error in recieved response from NON EXISTING burst id: %h",id))
				end
		end


// DID NOT GET RSP IN RESPONSE LATENES TIME -> DELET QUEUE ( check duplicate and decrement active burst )
//
//
//
//               ---------------------------------------------------------------------------
//   			|    done       |   	 done 				|waitin_to_rsp -> delete		|
//   -----------|---------------|-----------------------------------------------------------
// 	|  done 	| 		 		|							|					|
// 	 -----------|---------------|							 ------------------>
// 				| 			 	|							 response_latenes = 0
// 				 ---------------
//

		while(rsp_latenes_exipired_id_queue.size() != 0)
			begin
				id = rsp_latenes_exipired_id_queue.pop_front();

				burst_active--;
				check_for_Id_duplicates_id_queue.push_back(id);

				void'(findeIndexFromID(id,waiting_for_RSP_queue, index));
				waiting_for_RSP_queue.delete(index);
				//`uvm_warning("MasterWriteScheduler [ERROR]: ", $sformat(" did not recieved response for quite a longe time for burst id: %h",id))
			end


//  DUPLICATE ID CHECK
//
//
//
//               ---------------------------------------------------------------------------
//   			|    done       |           done  			|       done		|   done    |
//   -----------|---------------|-----------------------------------------------------------
// 	|  done 	| 		 		|							|					|
// 	 -----------|---------------|							 ------------------>
// 				| 			 	|							 response_latenes = 0
// 				 ---------------
//

		if(duplicate_ID_queue.size() != 0)
			begin
				while(check_for_Id_duplicates_id_queue.size() != 0)
					begin
						id = check_for_Id_duplicates_id_queue.pop_front();
						if(this.findeIndexFromID(id, duplicate_ID_queue, index) == TRUE)
							begin
								// if there is duplicate of this id translate it to inactive queue
								inactive_queue.push_back(duplicate_ID_queue[index]);
								duplicate_ID_queue.delete(index);
							end

					end
			end
		else
			begin
				check_for_Id_duplicates_id_queue.delete();
			end

//  ADD TO ACTIVE IF THERE IS PLACE IN ACTIVE SPOT
//
//
//
//               ---------------------------------------------------------------------------
//   			|    active     |           done  			|       done		|   done    |
//   -----------|----   |  -----|-----------------------------------------------------------
// 	|  done 	| 	inactive	|
// 	 -----------|---------------|
// 				| 	 done 	 	|
// 				 ---------------
//
		while(burst_active < burst_deepth && inactive_queue.size() > 0)
			begin
				axi_master_write_scheduler_package2_0 burst;
				burst = inactive_queue.pop_front();

				if(active_queue.size() == 0)
					begin
						burst.setLock_state(QUEUE_UNLOCKED);
					end
				else if(active_queue[active_queue.size()-1].getFirst_status == FIRST_SENT)
					begin
						burst.setLock_state(QUEUE_UNLOCKED);
					end
				else
					begin
						burst.setLock_state(QUEUE_LOCKED);
					end

					active_queue.push_back(burst);

					burst_active++;

			end

endtask
// ================================== END BURST MAnAGMENT =============================================


function true_false_enum axi_master_write_scheduler2_0::findeIndexFromID(input bit[ID_WIDTH-1:0] id_to_check, input package_queue queue_to_check, ref int index);
   int i;

	$display("finde index");
	PrintActive();
	foreach(queue_to_check[i])
		begin
			if(queue_to_check[i].getID() == id_to_check)
				begin
					$display("found index = %0d, searching id: %h", i, id_to_check);
					index = i;
					return TRUE;
				end
		end
	index = -1;
	return FALSE;
endfunction;


// ==================================== MANAGE RESPONSE ============================================

task axi_master_write_scheduler2_0::gotOkayResponse(input bit[ID_WIDTH-1 : 0] rsp_id, int index, input int where_is_burst_found);
//   	rsp_queue.delete(index);
//	top_driver.putResponseToSequencer(rsp_id);

	case(where_is_burst_found)
		1:
		begin
			waiting_for_RSP_queue.delete(index);
		end

		2:
		begin
			waiting_to_send_all_queue.delete(index);
		end

		3:
		begin
			//active_queue.delete(index);
		end
	endcase

endtask

task axi_master_write_scheduler2_0::gotExOkayResponse(input bit[ID_WIDTH-1 : 0] rsp_id, int index, input int where_is_burst_found);

	case(where_is_burst_found)
		1:
		begin
			waiting_for_RSP_queue.delete(index);
		end

		2:
		begin
			waiting_to_send_all_queue.delete(index);
		end

		3:
		begin
			active_queue.delete(index);
		end
	endcase

//	top_driver.putResponseToSequencer(rsp_id);
endtask

task axi_master_write_scheduler2_0::gotDecErrorResponse(input bit[ID_WIDTH-1 : 0] rsp_id, int index,  input int where_is_burst_found);
	case(where_is_burst_found)
		1:
		begin
			waiting_for_RSP_queue.delete(index);
		end

		2:
		begin
			waiting_to_send_all_queue.delete(index);
		end

		3:
		begin
			active_queue.delete(index);
		end
	endcase


//	top_driver.putResponseToSequencer(rsp_id);
endtask

task axi_master_write_scheduler2_0::gotSlaveErrorResponse(input bit[ID_WIDTH-1:0] rsp_id, input int index, input int where_is_burst_found);
	case(where_is_burst_found)
		1:
		begin
			if(waiting_for_RSP_queue[index].decrementError_counter() == TRUE)
				begin
					addBurst(waiting_for_RSP_queue[index].getFrameCopy());
			 		waiting_for_RSP_queue.delete(index);
				end
		end

		2:
		begin
			if(waiting_to_send_all_queue[index].decrementError_counter() == TRUE)
				begin
					addBurst(waiting_to_send_all_queue[index].getFrameCopy());
			 		waiting_to_send_all_queue.delete(index);
				end
		end

		3:
		begin
			if(active_queue[index].decrementError_counter() == TRUE)
				begin
					addBurst(active_queue[index].getFrameCopy());
			 	//	active_queue.delete(index);
				end
		end
	endcase


//	if(rsp_queue[index].decrementError_counter == FALSE)
//		begin
//			addBurst(rsp_queue[index].getFrameCopy());
//			 rsp_queue.delete(index);
//		end
//	else
//		begin
//			 rsp_queue.delete(index);
//		end
//	top_driver.putResponseToSequencer(rsp_id);
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

task axi_master_write_scheduler2_0::reset();
    // TODO Auto-generated task stub

endtask

function void axi_master_write_scheduler2_0::PrintActive();
    int i;
    foreach(active_queue[i])
	    begin
		    $display("inedx : %0d, ID: %h, items: %0d ",i, active_queue[i].getID(), active_queue[i].single_frame_queue.size() );
	    end

endfunction

`endif
