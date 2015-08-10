/******************************************************************************
	* DVT CODE TEMPLATE: component
	* Created by root on Aug 5, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//
//
//------------------------------------------------------------------------------

// TODO treba da se impelmentrira da scheduler moze da prati koji ID je bio i koji je zavrsen ako posalje sve a ne stigne
typedef enum {
	DELETE_ONE,
	NEXT_CHECK,
	CALCULATE_STATE
} state_check_ID_enum;

class randomize_data;
		rand int delay;
		rand int delay_addrdata;

		constraint delay_cst{
			delay inside {[0 : 50]}; // initial constraint - needst ti be reset for real testing
		}

		constraint deleay_addrdata_csr{
			delay_addrdata inside {[0:50]};
		}

endclass: randomize_data


class axi_master_write_scheduler extends uvm_component;

	axi_master_write_scheduler_packages burst_queue[$];
	axi_master_write_scheduler_packages burst_existing_id[$];
	axi_master_write_scheduler_packages single_burst;
	axi_single_frame next_frame_for_sending[$];
	axi_frame used_ID_queue[$];
	axi_frame frame_same_id;
	axi_mssg mssg;
	axi_mssg send;

	state_check_ID_enum state_check_ID = DELETE_ONE;   //check for same - new after deletion - ID


	static axi_master_write_scheduler scheduler_instance; // singleton
	semaphore sem;

	randomize_data rand_data; // randomize delays
	axi_single_frame tmp_data;

	virtual interface axi_if vif;
	int empyt_scheduler_packages[$];

	extern local function new(string name, uvm_component parent); // DONE
	extern function void addBurst(input axi_frame frame); // DONE
	extern function void buld();  // DONE
	extern function void serchForReadyFrame(); //DONE
	extern task main(); // DONE
	extern function void delayCalculator(); // DONE
	extern function axi_mssg getFrameForDrivingVif(); // DONE
	extern function void resetAll(); // DONE
	extern function void checkUniqueID(); // TODO

	extern static function axi_master_write_scheduler getSchedulerInstance(input uvm_component parent); // DONE

endclass : axi_master_write_scheduler

// CONSTRUCTOR
	function axi_master_write_scheduler::new (input string name, uvm_component parent);
		super.new(name,parent);
		mssg = new();

	endfunction : new

// BUILD
	function void axi_master_write_scheduler::buld();
		 if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
	     sem = new(1);
	endfunction

// ADD BURST
	function void axi_master_write_scheduler::addBurst(input axi_frame frame);
		int tmp_add = 0; 
		$write("\nadded new frame \n");

		single_burst = new();
		for(int i = 0; i<=frame.len; i++)
			begin
				rand_data = new();
				assert(rand_data.randomize);
				tmp_data = new();
				tmp_data.data = frame.data[i];
				tmp_data.addr = frame.addr;
				tmp_data.size = frame.size;
				tmp_data.burst_type = frame.burst_type;
				tmp_data.lock = frame.lock;
				tmp_data.id = frame.id;
				tmp_data.cache = frame.cache;
				tmp_data.prot = frame.prot;
				tmp_data.qos = frame.qos;
				tmp_data.region = frame.region;
				tmp_data.delay = rand_data.delay;
				tmp_data.delay_addrdata = rand_data.delay_addrdata;
				sem.get(1);
				single_burst.addSingleFrame(tmp_data);
				sem.put(1);
			end
		// if it is first then needs to be checked QUEUE UNLOCKED becuse it it first and does not need to wait to
		// sned first frame from previous burst. ( see rules of sending in AXI3 - this is AXI4 but darko wanted from
		// to implement this to play with code :D )
			sem.get(1);
			single_burst.ID = frame.id;
			if(burst_queue.size() == 0)
				single_burst.lock_state = QUEUE_UNLOCKED;
			else if(burst_queue[burst_queue.size()-1].first_status == FIRST_SENT)
				single_burst.lock_state = QUEUE_UNLOCKED;
			sem.put(1);
		// if there is samoe ID in queue then package is set to EXISTING_ID

			if(burst_queue.size() > 0)
			begin
				for(int j = 0; j < burst_queue.size(); j++)
				begin
					sem.get(1);
					 if (burst_queue[j].ID == frame.id) // seach for same ID
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
				burst_queue.push_back(single_burst); // push single burst package to burst_queue;
				sem.put(1);
			end 


	endfunction

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
//				int tmp_for_delete = empyt_scheduler_packages.pop_front();
//				burst_queue.delete(tmp_for_delete);
			end
	endfunction


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

	function void axi_master_write_scheduler::delayCalculator();
		int i;
		sem.get(1);
		foreach(burst_queue[i])
			begin
				burst_queue[i].decrementDelay();
			end
		sem.put(1);
	endfunction

	task axi_master_write_scheduler::main();
	    forever
		    begin
			    @(posedge vif.sig_clock);
			    this.delayCalculator;
			    this.serchForReadyFrame;
		    end
	endtask


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
					$display("DELETE ONE ***************************************************************************************************");

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






