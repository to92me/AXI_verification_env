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
class randomize_data;
		rand bit [7:0] delay;

		constraint delay_cst{
			delay inside {[0 : 50]}; // initial constraint - needst ti be reset for real testing
		}
endclass: randomize_data


class axi_master_write_scheduler extends uvm_object;

	axi_master_write_scheduler_packages burst_queue[$];
	axi_master_write_scheduler_packages single_burst;
	axi_single_frame next_frame_for_sending[$];
	axi_mssg mssg;

	static axi_master_write_scheduler scheduler_instance;

	randomize_data rand_data;
	axi_single_frame tmp_data; // MENJAO

	virtual interface axi_if vif;
	string name = "Master write scheduler";
	int empyt_scheduler_packages[$];

	extern local function new(); // DONE
	extern function void addBurst(input axi_frame frame); // DONE
	extern function void buld();  // DONE
	extern function void serchForReadyFrame(); //DONE
	extern task main(); // DONE
	extern function void delayCalculator(); // DONE
	extern function axi_single_frame getFrameForDrivingVif(); // DONE
	extern function void resetAll(); // DONE

	extern static function axi_master_write_scheduler getSchedulerInstance();

endclass : axi_master_write_scheduler


	function axi_master_write_scheduler::new (string name, uvm_component parent);
		super.new(name, parent);
		mssg = new();

	endfunction : new

	function void axi_master_write_scheduler::buld();
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
	endfunction

	function void axi_master_write_scheduler::addBurst(input axi_frame frame);
		single_burst = new();
//		for( int i = 0; i <= frame.len; i++)
//			begin
//				assert(rand_data.randomize);
//				tmp_data = new();
//				tmp_data.frame = frame;
//				tmp_data.delay = rand_data.delay;
//				tmp_data.frame.data = rand_data.data;
//				single_burst.addSingleFrame(tmp_data);
//			end

		for(int i = 0; i<=frame.len; i++)
			begin
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
				single_burst.addSingleFrame(tmp_data);
			end
			burst_queue.push_front(single_burst);
	endfunction

	function void axi_master_write_scheduler::serchForReadyFrame();
		int i;
//		int smallest_delay = -1;
		foreach(burst_queue[i])
			begin
				mssg = burst_queue[i].getNextSingleFrame();
				if(mssg.state == axi_mssg_enum::READY)
					next_frame_for_sending.push_front(mssg.frame);
				else if(mssg.state == axi_mssg_enum::QUEUE_EMPTY)
					empyt_scheduler_packages.push_front(i);
			end

		while(empyt_scheduler_packages.size() > 0)
			begin
				int tmp_for_delete = empyt_scheduler_packages.pop_front();
				burst_queue.delete(tmp_for_delete);
			end
	endfunction


	function axi_single_frame axi_master_write_scheduler::getFrameForDrivingVif();
	    if(next_frame_for_sending.size() > 0)
		    return next_frame_for_sending.pop_back();
	    else
		    return null;
	endfunction

	function void axi_master_write_scheduler::delayCalculator();
		int i;
		foreach(burst_queue[i])
			begin
				burst_queue[i].decrementDelay();
			end
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
		for(int  i = 0; i <= burst_queue.size(); i++ )
			burst_queue.pop_front();
		for(int i = 0; i<= next_frame_for_sending.size(); i++ )
			next_frame_for_sending.pop_front();
		`uvm_info("AXI MASTER WRITE SCHEDULER", "recived reset signal, deleting all bursts and items",UVM_HIGH);
	endfunction


	function axi_master_write_scheduler axi_master_write_scheduler::getSchedulerInstance();
	   if(scheduler_instance == null)
		   begin
			   $display("Creating Scheduler");
			   scheduler_instance = new();
		   end
		   return scheduler_instance;
	endfunction
