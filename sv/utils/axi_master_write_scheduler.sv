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
	NEXT_FRAME,
	NEXT_BURST_PACKAGE,
	NEW_ID,
	DONE
} state_check_ID_enum;

class randomize_data;
		rand int delay;
		rand int delay_addrdata;

		constraint delay_cst{
			delay inside {[0 : 50]}; // initial constraint - needst ti be reset for real testing
		}
endclass: randomize_data


class axi_master_write_scheduler extends uvm_component;

	axi_master_write_scheduler_packages burst_queue[$];
	axi_master_write_scheduler_packages single_burst;
	axi_single_frame next_frame_for_sending[$];
	axi_frame used_ID_queue[$];
	axi_frame frame_same_id;
	axi_mssg mssg;
	axi_mssg send;

	state_check_ID_enum state_check_ID;


	static axi_master_write_scheduler scheduler_instance;
	semaphore sem;

	randomize_data rand_data;
	axi_single_frame tmp_data;

	virtual interface axi_if vif;
	int empyt_scheduler_packages[$];

	extern local function new(string name, uvm_component parent); // DONE
	extern function void addBurst(input axi_frame frame); // DONE
	extern local function void buld();  // DONE
	extern function void serchForReadyFrame(); //DONE
	extern task main(); // DONE
	extern function void delayCalculator(); // DONE
	extern function axi_mssg getFrameForDrivingVif(); // DONE
	extern function void resetAll(); // DONE
	extern function void addBurstFromQueue();

	extern static function axi_master_write_scheduler getSchedulerInstance(input uvm_component parent);

endclass : axi_master_write_scheduler


	function axi_master_write_scheduler::new (input string name, uvm_component parent);
		super.new(name,parent);
		mssg = new();

	endfunction : new

	function void axi_master_write_scheduler::buld();
		 if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
	     sem = new(1);
	endfunction

	function void axi_master_write_scheduler::addBurst(input axi_frame frame);
		int j;
		$write("added new frame");
		if(burst_queue.size() > 0)
			begin
				sem.get(1);
				foreach(burst_queue[j])
					begin
						if(frame.id == burst_queue[j].queu_id);
						used_ID_queue.push_front(frame);
						sem.put(1);
						return;
					end
					$display("new unique ID");
					sem.put(1);
			end
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
			if(burst_queue.size() == 0)
				single_burst.lock_state = QUEUE_UNLOCKED;
			sem.get(1);
			burst_queue.push_back(single_burst);
			sem.put(1);
	endfunction

	function void axi_master_write_scheduler::serchForReadyFrame();
		int i;
//		int smallest_delay = -1;
		foreach(burst_queue[i])
			begin
				if(burst_queue[i].lock_state == QUEUE_LOCKED)
					break;

				mssg = burst_queue[i].getNextSingleFrame();
				if(mssg.state == READY)
					begin
						next_frame_for_sending.push_front(mssg.frame);
						burst_queue[i+1].lock_state = QUEUE_UNLOCKED;
					end
				else if(mssg.state == QUEUE_EMPTY)
					empyt_scheduler_packages.push_front(i);

			end
		while(empyt_scheduler_packages.size() > 0)
			begin
				int tmp_for_delete = empyt_scheduler_packages.pop_front();
				burst_queue.delete(tmp_for_delete);
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
		for(int  i = 0; i <= burst_queue.size(); i++ )
			void'(burst_queue.pop_front());
		for(int i = 0; i<= next_frame_for_sending.size(); i++ )
			void'(next_frame_for_sending.pop_front());
		`uvm_info("AXI MASTER WRITE SCHEDULER", "recived reset signal, deleting all bursts and items",UVM_HIGH);
		sem.put(1);
	endfunction


	function axi_master_write_scheduler axi_master_write_scheduler::getSchedulerInstance(input uvm_component parent);
	   if(scheduler_instance == null)
		   begin
			   $display("Creating Scheduler");
			   scheduler_instance = new("master scheduler", parent);
			   this.build;
		   end
		   return scheduler_instance;
	endfunction

	function axi_master_write_scheduler::addBurstFromQueue();
		//TODO impelemirato dodavanje;
	endfunction





