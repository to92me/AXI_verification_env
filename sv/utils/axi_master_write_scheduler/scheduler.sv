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
	axi_waiting_resp						single_waiting_for_resp;
	axi_master_write_scheduler_packages 	single_burst;
	axi_single_frame 						next_frame_for_sending[$];
	axi_single_frame 						next_address_for_sending[$];
	axi_frame 								used_ID_queue[$];
	axi_frame 								frame_same_id;
	axi_mssg 								mssg;
	axi_mssg 								send;
	int 									response_latenes_error_rising = 100;
	axi_slave_response						response_from_slave_queue[$];
	axi_slave_response						single_response_from_slave;
	int 									error_before_delte_item = 4;
//	mailbox 								mbx;


	state_check_ID_enum state_check_ID = DELETE_ONE;   //check for same - new after deletion - ID


	static axi_master_write_scheduler scheduler_instance; // singleton
	semaphore sem;

	randomize_data rand_data; // randomize delays
	axi_single_frame tmp_data;

	virtual interface axi_if vif;
	int empyt_scheduler_packages[$];

	extern local function new(string name, uvm_component parent); // DONE
	extern function void addBurst(input axi_frame frame); // DONE
	extern  function void serchForReadyFrame(); //DONE
	extern task main(input int clocks); // DONE
	extern  function void delayCalculator(); // DONE
	extern function axi_mssg getFrameForDrivingVif(); // DONE
	extern function void resetAll(); // DONE
	extern local function void checkUniqueID(); // DONE
	extern function void putResponseFromSlave(input axi_slave_response rsp); //DONE
	extern local function void calculateRepsonseLatenes(); //DONE
	extern local function void errorFromSlaveRepetaTransaction(input bit[ID_WIDTH - 1 : 0] rsp_id ); //DONE
	extern local function void readSlaveResponse(); // DONE
	extern local function void putOkResp(input bit[ID_WIDTH - 1 : 0] rsp_id );
	extern local function void errorFromSlaveDecError(input bit[ID_WIDTH - 1 : 0] rsp_id); // DONE
	extern local function void removeBurstAndCheckExisintgID(input bit[ID_WIDTH - 1 : 0] rsp_id);




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
	function void axi_master_write_scheduler::addBurst(input axi_frame frame);
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
				sem.get(1);
				single_burst.addSingleFrame(tmp_data);
				sem.put(1);
			end

			$display("\nadded new frame, size: %d  \n ", single_burst.size());

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
	endfunction

// SEARCH FOR READY FRAME
	function void axi_master_write_scheduler::serchForReadyFrame();
		int i;
//		int smallest_delay = -1;
		foreach(burst_queue[i])
			begin

				mssg = burst_queue[i].getNextSingleFrame();
				if(mssg.state == READY)
					begin
						next_frame_for_sending.push_front(mssg.frame);
						if(burst_queue[i+1] != null)
							burst_queue[i+1].lock_state = QUEUE_UNLOCKED;
					end
				else if(mssg.state == QUEUE_EMPTY)
					empyt_scheduler_packages.push_front(i);

			end
		while(empyt_scheduler_packages.size() > 0)
			begin
				checkUniqueID();
			end
	endfunction

// GET FRAME FOR DRIVING VIF
	function axi_mssg axi_master_write_scheduler::getFrameForDrivingVif();
		int tmp;
		send = new();
		sem.get(1);
		tmp = next_frame_for_sending.size();
		sem.put(1);
	    if(tmp > 0)
		    begin
		    send.frame  = next_frame_for_sending.pop_back();
	    	send.state = READY;
		    end
	    else
		    begin
			    send.state = QUEUE_EMPTY;
			    send.frame = null;
		    end

		return send;
	endfunction

// DELAY CALCULATOR
	function void axi_master_write_scheduler::delayCalculator();
		int i;
		sem.get(1);
		foreach(burst_queue[i])
			begin
				burst_queue[i].decrementDelay();
			end
		sem.put(1);
	endfunction

	task axi_master_write_scheduler::main(input int clocks);
//		$display("scheduler clock %d", clocks);
	    repeat(clocks)
		    begin
			    this.delayCalculator;
			    this.serchForReadyFrame;
		    end
	endtask

// reset all queues and
	function void axi_master_write_scheduler::resetAll();
		sem.get(1);
		for(int  i = 0; i < burst_queue.size(); i++ )
			void'(burst_queue.pop_front());
		for(int i = 0; i< next_frame_for_sending.size(); i++ )
			void'(next_frame_for_sending.pop_front());
		for(int i = 0; i<burst_existing_id.size(); i++)
			void'(burst_existing_id.pop_front());
		`uvm_info("AXI MASTER WRITE SCHEDULER", "recived reset signal, deleting all bursts and items",UVM_HIGH);
		sem.put(1);
	endfunction


	function axi_master_write_scheduler axi_master_write_scheduler::getSchedulerInstance(input uvm_component parent);
	   if(scheduler_instance == null)
		   begin
			   $display("Creating Scheduler");
			   scheduler_instance = new("master scheduler", parent);
			   // scheduler_instance.build(); // TODO FIXBUG
		   end
		   return scheduler_instance;
	endfunction


	function void axi_master_write_scheduler::checkUniqueID();
		int check_ID;
		int done = 0;
		int tmp_for_delete;
		int i;
		while(!done)
		begin
			case (state_check_ID)
				CALCULATE_STATE:
				begin
					i = 0;
					sem.get(1);
					if(empyt_scheduler_packages.size() == 0)
						done = 1;
					else
						state_check_ID = DELETE_ONE;
					sem.put(1);
				end


				DELETE_ONE:
				begin
					i = 0;
					sem.get(1);
					tmp_for_delete = empyt_scheduler_packages.pop_front();									 // check for next one to be first
					state_check_ID = NEXT_CHECK;
					check_ID = burst_queue[tmp_for_delete].ID;

					single_waiting_for_resp = new();														// create copy of frame
					single_waiting_for_resp.frame = burst_queue[tmp_for_delete].frame_copy;
					single_waiting_for_resp.counter = 0;

					waiting_for_resp_queue.push_back(single_waiting_for_resp);
					//$display("DELETE ONE ***************************************************************************************************");
					burst_queue.delete(tmp_for_delete); //deleted complited burst_package
					sem.put(1);
				end

				NEXT_CHECK:
				begin
					sem.get(1);
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
								sem.put(1);
								state_check_ID = CALCULATE_STATE;
							end
						else
							begin
								sem.put(1);
								state_check_ID = NEXT_CHECK;
								i++;
								if(i == burst_existing_id.size())
									state_check_ID = CALCULATE_STATE;

							end
						end
				end
			endcase // end case
		end // end while
	endfunction


function void axi_master_write_scheduler::calculateRepsonseLatenes();
	int foreach_i;

	sem.get(1);
	if(waiting_for_resp_queue.size != 0)
		begin
			foreach(waiting_for_resp_queue[foreach_i])
				begin
					waiting_for_resp_queue[foreach_i].counter++;
					if(	waiting_for_resp_queue[foreach_i].counter > response_latenes_error_rising)
						begin
							`uvm_info(get_name(),$sformatf("for burst ID: %d response did not come after %d",
								waiting_for_resp_queue[foreach_i].frame.id, response_latenes_error_rising), UVM_HIGH)
						end
				end
		end
	sem.put(1);

endfunction


function void axi_master_write_scheduler::putResponseFromSlave(input axi_slave_response rsp);
	sem.get(1);
		response_from_slave_queue.push_back(rsp);
	sem.put(1);

endfunction


function void axi_master_write_scheduler::readSlaveResponse();
	while(1)
		begin
		sem.get(1);
		if(waiting_for_resp_queue.size == 0)
			begin
				sem.put(1);
				return;
			end
		else
			begin
				single_waiting_for_resp = waiting_for_resp_queue.pop_front();
				sem.put(1);
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
		end

endfunction


function void axi_master_write_scheduler::putOkResp(input bit[ID_WIDTH-1:0] rsp_id);
 	int tmp_size;
	sem.get(1);
	tmp_size = waiting_for_resp_queue.size();
	sem.put(1);

	for(int i = 0; i < tmp_size-1 ;i++)
		begin
			sem.get(1);
			if(waiting_for_resp_queue[i].frame.id == rsp_id)
				begin
					`uvm_info(get_name(),$sformatf("burst ID: %d recivede OK or EXOKAY from slave,\
						 completeing transaction and deleteing frame",rsp_id), UVM_MEDIUM)
					waiting_for_resp_queue.delete(i);
					sem.put(1);
					return;
				end
				sem.put(1);
		end
	$display("EROOR recieved OK response for not existing or not conmlited burst, rsp ID: %d", rsp_id);
//	`uvm_info(get_name(),$sformatf("recieved resp with ID: %d and there is no complited burst with that ID "rsp_id), UVM_ERROR)

endfunction

function void axi_master_write_scheduler::errorFromSlaveDecError(input bit[ID_WIDTH-1:0] rsp_id);
	this.removeBurstAndCheckExisintgID(rsp_id);
endfunction

function void axi_master_write_scheduler::errorFromSlaveRepetaTransaction(input bit[ID_WIDTH-1:0] rsp_id);
	sem.get(1);
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
		sem.put(1);

endfunction

function void axi_master_write_scheduler::removeBurstAndCheckExisintgID(input bit[ID_WIDTH - 1 : 0] rsp_id); // za sada se samo odavde poziva i onda ne mora da vide lockovan semaphore
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
endfunction











`endif







