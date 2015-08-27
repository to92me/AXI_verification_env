`ifndef AXI_MASTER_WRITE_SCHEDULER_SVH
`define AXI_MASTER_WRITE_SCHEDULER_SVH


//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//
//
//------------------------------------------------------------------------------

typedef enum {
	DELETE_ONE,
	NEXT_CHECK,
	CALCULATE_STATE
} state_check_ID_enum;


class axi_master_write_scheduler extends uvm_component;

	axi_master_write_scheduler_packages 	burst_queue[$];
	axi_master_write_scheduler_packages 	burst_existing_id[$];
	axi_waiting_resp						waiting_for_resp_queue[$];
	bit[ID_WIDTH - 1: 0] 					burst_empyt_queue[$];
	axi_waiting_resp						single_waiting_for_resp;
	axi_master_write_scheduler_packages 	single_burst;
	axi_single_frame 						next_frame_for_sending[$];
	axi_single_frame 						next_address_for_sending[$];
	axi_frame 								used_ID_queue[$];
	axi_frame 								frame_same_id;
	axi_mssg 								mssg;
	axi_mssg 								send;
	int 									response_latenes_error_rising = 100000;
	axi_slave_response						response_from_slave_queue[$];
	axi_slave_response						single_response_from_slave;
	int 									error_before_delte_item = 4;
//	mailbox 								mbx;


	state_check_ID_enum state_check_ID = DELETE_ONE;   //check for same - new after deletion - ID


	static axi_master_write_scheduler scheduler_instance; // singleton
	semaphore sem;
	axi_master_write_driver					top_driver;

	randomize_data rand_data; // randomize delays
	axi_single_frame tmp_data;

	virtual interface axi_if vif;
	int empyt_scheduler_packages[$];

	extern local function new(string name, uvm_component parent); // DONE
	extern task addBurst(input axi_frame frame); // DONE
	extern task serchForReadyFrame(); //DONE
	extern task main(input int clocks); // DONE
	extern task delayCalculator(); // DONE
	extern task  getFrameForDrivingVif(output axi_mssg mssg); // DONE
	extern task resetAll(); // DONE
	extern local task checkUniqueID(); // DONE
	extern task putResponseFromSlave(input axi_slave_response rsp); //DONE
	extern task  calculateRepsonseLatenes(); //DONE
	extern task  errorFromSlaveRepetaTransaction(input bit[ID_WIDTH - 1 : 0] rsp_id ); //DONE
	extern local task readSlaveResponse(); // DONE
	extern local task putOkResp(input bit[ID_WIDTH - 1 : 0] rsp_id );
	extern local task errorFromSlaveDecError(input bit[ID_WIDTH - 1 : 0] rsp_id); // DONE
	extern local task removeBurstAndCheckExisintgID(input bit[ID_WIDTH - 1 : 0] rsp_id);
	extern local task checkForDone();
	extern function  void setTopDriverInstance(input axi_master_write_driver top_driver_instance);




	extern static function axi_master_write_scheduler getSchedulerInstance(input uvm_component parent); // DONE

endclass : axi_master_write_scheduler

// CONSTRUCTOR
	function axi_master_write_scheduler::new (input string name, uvm_component parent);
		super.new(name,parent);
		mssg = new();
		single_response_from_slave = new();
		sem = new(1);
	endfunction : new

// ADD BURST
	task axi_master_write_scheduler::addBurst(input axi_frame frame);
		int tmp_add = 0;


		single_burst = new();
		for(int i = 0; i<=frame.len; i++)

			begin
				rand_data = new();
				assert(rand_data.randomize);
				tmp_data = new();
				tmp_data.data 				= frame.data[i];
				tmp_data.addr 				= frame.addr;
				tmp_data.size 				= frame.size;
				tmp_data.burst_type 		= frame.burst_type;
				tmp_data.lock 				= frame.lock;
				tmp_data.id 				= frame.id;
				tmp_data.cache 				= frame.cache;
				tmp_data.prot 				= frame.prot;
				tmp_data.qos 				= frame.qos;
				tmp_data.region 			= frame.region;
				tmp_data.delay 				= rand_data.delay;
				tmp_data.delay_addr 		= rand_data.delay_addr;
				tmp_data.delay_data 		= rand_data.delay_data;
				tmp_data.delay_awvalid 		= rand_data.delay_awvalid;
				tmp_data.delay_wvalid 		= rand_data.delay_wvalid;
				tmp_data.last_one 			= FALSE;
				tmp_data.len				= frame.len+1;
				sem.get(1);
				single_burst.addSingleFrame(tmp_data);
				sem.put(1);

//				$display("item id: %d data %d", tmp_data.id, tmp_data.data);
			end

//			$display("\nadded new frame, size: %d  \n ", single_burst.size());

			sem.get(1);
			single_burst.frame_copy = frame; // keep the frame copy if recieved error repeat transaction
			single_burst.ID = frame.id;
			single_burst.data_queue[single_burst.size() -1].last_one = TRUE;
			single_burst.data_queue[0].first_one = TRUE;

			if(burst_queue.size() == 0)
				single_burst.lock_state = QUEUE_UNLOCKED;
			else if(burst_queue[burst_queue.size()-1].first_status == FIRST_SENT)
				single_burst.lock_state = QUEUE_UNLOCKED;
			sem.put(1);


			if(burst_queue.size() > 0)
			begin
				for(int j = 0; j < burst_queue.size(); j++)
				begin
					sem.get(1);
					 if (burst_queue[j].ID == frame.id)
					 begin
						`uvm_info("AXI MASTER WRITE SCHEDULER", "adding existing burst_package",UVM_HIGH);
						 burst_existing_id.push_back(single_burst);
						 tmp_add = 1;
					 end
					sem.put(1);
				end
			end

			if(!tmp_add)
			begin
				`uvm_info("AXI MASTER WRITE SCHEDULER", "adding burst_package",UVM_HIGH);
				sem.get(1);
				burst_queue.push_back(single_burst);
				sem.put(1);
			end
	endtask

// SEARCH FOR READY FRAME
	task axi_master_write_scheduler::serchForReadyFrame();
		int i;
//		int smallest_delay = -1;
		foreach(burst_queue[i])
			begin

				burst_queue[i].getNextSingleFrame(mssg);
				if(mssg.state == READY)
					begin
						next_frame_for_sending.push_front(mssg.frame);
//						$display("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++Scheduler ready frame ");
						if(burst_queue[i+1] != null)
							burst_queue[i+1].lock_state = QUEUE_UNLOCKED;
					end
				else if(mssg.state == QUEUE_EMPTY)
					begin
						$display("frame copy id: %h",burst_queue[i].frame_copy.id);
						burst_empyt_queue.push_front(burst_queue[i].ID);
//						burst_queue.delete(i);
					end
			end
		while(burst_empyt_queue.size() > 0)
			begin
				checkUniqueID();
			end
	endtask

// GET FRAME FOR DRIVING VIF
	task axi_master_write_scheduler::getFrameForDrivingVif(output axi_mssg mssg);
		int tmp;
		send = new();
//		sem.get(1);
		tmp = next_frame_for_sending.size();
//		sem.put(1);
	    if(tmp > 0)
		    begin
//			sem.get(1);
		    send.frame  = next_frame_for_sending.pop_back();
	    	send.state = READY;
//			sem.put(1);
		    end
	    else
		    begin
//			    sem.get(1);
			    send.state = QUEUE_EMPTY;
			    send.frame = null;
//			    sem.put(1);
		    end

		mssg = send;
	endtask

// DELAY CALCULATOR
	task axi_master_write_scheduler::delayCalculator();
		int i;

//		sem.get(1);
		foreach(burst_queue[i])
			begin

				burst_queue[i].decrementDelay();

			end
//		sem.put(1);

	endtask

	task axi_master_write_scheduler::main(input int clocks);
//		$display("scheduler clock %d", clocks);
	    repeat(clocks)
		    begin
//			    $display("SCHEDULER CLOCK ");
			    this.delayCalculator();
			    this.serchForReadyFrame();
			    this.calculateRepsonseLatenes();
		    end
		readSlaveResponse();
	endtask

// reset all queues and
	task axi_master_write_scheduler::resetAll();
//		sem.get(1);
		for(int  i = 0; i < burst_queue.size(); i++ )
			void'(burst_queue.pop_front());
		for(int i = 0; i< next_frame_for_sending.size(); i++ )
			void'(next_frame_for_sending.pop_front());
		for(int i = 0; i<burst_existing_id.size(); i++)
			void'(burst_existing_id.pop_front());
		`uvm_info("AXI MASTER WRITE SCHEDULER", "recived reset signal, deleting all bursts and items",UVM_HIGH);
//		sem.put(1);
	endtask


	function axi_master_write_scheduler axi_master_write_scheduler::getSchedulerInstance(input uvm_component parent);
	   if(scheduler_instance == null)
		   begin
			   $display("Creating Scheduler");
			   scheduler_instance = new("master scheduler", parent);
		   end
		   return scheduler_instance;
	endfunction


	task axi_master_write_scheduler::checkUniqueID();
		int check_ID;
		int done = 0;
		int tmp_for_delete;
		int i;
		int itertator;
		int tmp_iterator;
		axi_master_write_scheduler_packages sch_package;

		sch_package = new();

		while(!done)
		begin
			case (state_check_ID)
				CALCULATE_STATE:
				begin
					i = 0;
//					sem.get(1);
					if(burst_empyt_queue.size() == 0)
						begin
							done = 1;
							state_check_ID = CALCULATE_STATE;
						end
					else
						state_check_ID = DELETE_ONE;
//					sem.put(1);
				end


				DELETE_ONE:
				begin
					i = 0;
//					single_waiting_for_resp = new();
////					$display("ID: %h", burst_empyt_queue[0].ID);
//
//					single_waiting_for_resp.frame = burst_empyt_queue[0].frame_copy;
//					single_waiting_for_resp.counter = 0;
//					check_ID = single_waiting_for_resp.frame.id;
//					waiting_for_resp_queue.push_back(single_waiting_for_resp);
//					burst_empyt_queue.delete(0);
					check_ID = burst_empyt_queue.pop_front();
					$display("tome: %h",check_ID);
					foreach(burst_queue[itertator])
						begin
							if(burst_queue[itertator].ID == check_ID)
								begin
									single_waiting_for_resp = new();														// create copy of frame
									single_waiting_for_resp.frame = burst_queue[itertator].frame_copy;
									single_waiting_for_resp.counter = 0;
									$display("tome 2 %h", single_waiting_for_resp.frame.id);
									tmp_iterator = itertator;
								end
						end
					waiting_for_resp_queue.push_back(single_waiting_for_resp);
					burst_queue.delete(tmp_iterator);

//					sem.get(1);
//					check_ID = empyt_scheduler_packages.pop_front();									 // check for next one to be first
					state_check_ID = NEXT_CHECK;
//					check_ID = burst_queue[tmp_for_delete].ID;
//					$display("check ID: %d", check_ID);
//					single_waiting_for_resp = new();														// create copy of frame
//					single_waiting_for_resp.frame = burst_queue[tmp_for_delete].frame_copy;
//					single_waiting_for_resp.counter = 0;
//					$display("adding burst frame for complete ID: %d", single_waiting_for_resp.frame.id);
//					waiting_for_resp_queue.push_back(single_waiting_for_resp);
					//$display("DELETE ONE ***************************************************************************************************");
//					burst_queue.delete(tmp_for_delete); //deleted complited burst_package
//					sem.put(1);
				end

				NEXT_CHECK:
				begin
//					sem.get(1);
					if(burst_existing_id[i] == null)
						state_check_ID = CALCULATE_STATE;
					else
					begin
						if(burst_existing_id[i].ID == check_ID)
							begin
								if(burst_queue.size() == 0)
									burst_existing_id[i].lock_state = QUEUE_UNLOCKED;
								burst_queue.push_back(burst_existing_id[i]);
								burst_existing_id.delete(i);
//								sem.put(1);
								state_check_ID = CALCULATE_STATE;
							end
						else
							begin
//								sem.put(1);
								state_check_ID = NEXT_CHECK;
								i++;
								if(i == burst_existing_id.size())
									state_check_ID = CALCULATE_STATE;

							end
						end
				end
			endcase // end case
		end // end while
	endtask


task axi_master_write_scheduler::calculateRepsonseLatenes();
	int foreach_i;
	int tmp_i[$];

//	sem.get(1);
	if(waiting_for_resp_queue.size != 0)
		begin
			foreach(waiting_for_resp_queue[foreach_i])
				begin
					waiting_for_resp_queue[foreach_i].counter++;
					if(	waiting_for_resp_queue[foreach_i].counter > response_latenes_error_rising)
						begin
							`uvm_info(get_name(),$sformatf("for burst ID: %d response did not come after %d",
								waiting_for_resp_queue[foreach_i].frame.id, response_latenes_error_rising), UVM_HIGH)
							tmp_i.push_front(foreach_i);
						end
				end
		end

		foreach(tmp_i[foreach_i])
			begin
				waiting_for_resp_queue.delete(foreach_i);
			end

		this.checkForDone();
//	sem.put(1);

endtask


task axi_master_write_scheduler::putResponseFromSlave(input axi_slave_response rsp);
//	sem.get(1);
		response_from_slave_queue.push_back(rsp);
//	sem.put(1);

endtask


task axi_master_write_scheduler::readSlaveResponse();
	while(1)
		begin
//		sem.get(1);
//		if(waiting_for_resp_queue.size == 0)
			if(response_from_slave_queue.size == 0)
			begin
//				sem.put(1);
				return;
			end
		else
			begin
//				single_waiting_for_resp = waiting_for_resp_queue.pop_front();
				single_response_from_slave = response_from_slave_queue.pop_front();
//				sem.put(1);
			end

		case (single_response_from_slave.rsp) // check for  response
			OKAY:
			begin
				this.putOkResp(single_response_from_slave.ID);
			end

			EXOKAY:
			begin
				this.putOkResp(single_response_from_slave.ID); //FIXME
			end

			DECERR:
			begin
				this.errorFromSlaveDecError(single_response_from_slave.ID);
			end

			SLVERR:
			begin
				this.errorFromSlaveRepetaTransaction(single_response_from_slave.ID);
			end

		endcase

			this.checkForDone();

		end

endtask


task axi_master_write_scheduler::putOkResp(input bit[ID_WIDTH-1:0] rsp_id);
 	int tmp_size;
//	sem.get(1);
	tmp_size = waiting_for_resp_queue.size();
//	sem.put(1);

	for(int i = 0; i < tmp_size ;i++)
		begin
//			sem.get(1);
			if(waiting_for_resp_queue[i].frame.id == rsp_id)
				begin
					`uvm_info(get_name(),$sformatf("burst ID: %d recivede OK or EXOKAY from slave,\
						 completeing transaction and deleteing frame",rsp_id), UVM_MEDIUM)
					waiting_for_resp_queue.delete(i);
					sem.put(1);
					return;
				end
//				sem.put(1);
		end
	$display("ERROR recieved OK response for not existing or not conmlited burst, rsp ID: %h", rsp_id);
//	`uvm_info(get_name(),$sformatf("recieved resp with ID: %d and there is no complited burst with that ID "rsp_id), UVM_ERROR)

endtask

task axi_master_write_scheduler::errorFromSlaveDecError(input bit[ID_WIDTH-1:0] rsp_id);
	this.removeBurstAndCheckExisintgID(rsp_id);
endtask

task axi_master_write_scheduler::errorFromSlaveRepetaTransaction(input bit[ID_WIDTH-1:0] rsp_id);
//	sem.get(1);
	for(int i = 0; i < burst_queue.size()-1; i++)
		begin
			if(burst_queue[i].ID == rsp_id)
				begin
					if(burst_queue[i].getErrorCounter() < this.error_before_delte_item )
						burst_queue[i].reincarnate();
					else
						this.removeBurstAndCheckExisintgID(rsp_id);
				end
		end
//		sem.put(1);

endtask

task axi_master_write_scheduler::removeBurstAndCheckExisintgID(input bit[ID_WIDTH - 1 : 0] rsp_id); // za sada se samo odavde poziva i onda ne mora da vide lockovan semaphore
	for(int i = 0;i < burst_queue.size()-1; i++ )
		begin
			if(burst_queue[i].ID == rsp_id)
				begin
					burst_queue.delete(i);
				end
		end
	for(int i = 0; i < burst_existing_id.size()-1; i++)
		begin
			if(burst_existing_id[i].ID == rsp_id)
				begin
					if(burst_queue.size() == 0)
						burst_existing_id[i].lock_state = QUEUE_UNLOCKED;
					burst_queue.push_back(burst_existing_id[i]);
					burst_existing_id.delete(i);
				end
		end
endtask


function void axi_master_write_scheduler::setTopDriverInstance(input axi_master_write_driver top_driver_instance);
    this.top_driver = top_driver_instance;
endfunction



task axi_master_write_scheduler::checkForDone();

   if(burst_queue.size() == 0 && burst_existing_id.size() == 0 && waiting_for_resp_queue.size() == 0)
	   begin
	   	$display("  ============================= THE END =====================================");
	   	top_driver.putResponseToSequencer();
	   end
   else
	   begin
//		   $display("CHECKING COMPLETNES: burst_size: %d, burst_existing size: %d, wairing rsp size: %d",burst_queue.size(),burst_existing_id.size(), waiting_for_resp_queue.size());
	   end
endtask




`endif







