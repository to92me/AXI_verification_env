/******************************************************************************
	* DVT CODE TEMPLATE: component
	* Created by root on Aug 5, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_master_write_arbitration_burst
//
//------------------------------------------------------------------------------
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



class axi_master_write_scheduler_packages;

	axi_single_frame 		data_queue[$];
	axi_single_frame 		tmp_single_frame;
	axi_single_frame 		one_frame;
	axi_mssg			 	mssg;
	int 					items_in_queue = 0;
	burst_queue_lock_enum	lock_state = QUEUE_LOCKED;
	unique_id_struct 		burst_status;
	first_sent_enum 		first_status = FIRST_NOT_SENT;
	bit [ID_WIDTH-1 : 0] 	ID;
	axi_frame 				frame_copy;
	int 					slave_error_counter = 0;
	randomize_data 			rand_data;
	semaphore 				sem;

	function new ();
		one_frame = new();
		burst_status = new();
		rand_data = new();
		sem = new(1);
		tmp_single_frame = new();
	endfunction : new


	extern function axi_mssg getNextSingleFrame();
	extern function void decrementDelay();
	extern function void addSingleFrame(input axi_single_frame frame_for_push);
	extern function int size();
	extern function void addBurst(input axi_frame frame);
	extern local function void empyQueue();
	extern function void reincarnate();
	extern function void resetErrorCounter();
	extern function int incrementErrorCounter(); // it returns state = number of error counter
	extern function int getErrorCounter();



endclass : axi_master_write_scheduler_packages



function axi_mssg axi_master_write_scheduler_packages::getNextSingleFrame();
	mssg = new();
	// if queue is empty then return QUEUE_EMPTY
	if(data_queue.size == 0)
		begin
			mssg.state = QUEUE_EMPTY;
			mssg.frame = null;
			return mssg;
		end
	// if there is ready data return that and status READY
	// else return NOT_READY

	one_frame = data_queue.pop_front();
	if (one_frame.delay == 0)
		begin
		mssg.state = READY;
		mssg.frame = one_frame;
		items_in_queue--;
		first_status = FIRST_SENT;
		end
	else
		begin
		mssg.state = NOT_READY;
		mssg.frame = null;
		data_queue.push_front(one_frame);
		end
	return mssg;
endfunction


function void axi_master_write_scheduler_packages::decrementDelay();
	one_frame = data_queue.pop_front;
	if(one_frame != null)
	begin
		if (one_frame.delay != 0)
			one_frame.delay--;
		data_queue.push_front(one_frame);
	end
endfunction: decrementDelay

function void axi_master_write_scheduler_packages::addSingleFrame(input axi_single_frame frame_for_push);
	// $write(" added data to queu \n");
	items_in_queue++;
    data_queue.push_front(frame_for_push);
endfunction

function int axi_master_write_scheduler_packages::size();
    return(data_queue.size);
endfunction

function void axi_master_write_scheduler_packages::addBurst(input axi_frame frame);
		int tmp_add = 0;
		$write("\nadded new frame \n");

		for(int i = 0; i<=frame.len; i++)
			begin
				rand_data = new();
				assert(rand_data.randomize);
				tmp_single_frame = new();
				tmp_single_frame.data = frame.data[i];
				tmp_single_frame.addr = frame.addr;
				tmp_single_frame.size = frame.size;
				tmp_single_frame.burst_type = frame.burst_type;
				tmp_single_frame.lock = frame.lock;
				tmp_single_frame.id = frame.id;
				tmp_single_frame.cache = frame.cache;
				tmp_single_frame.prot = frame.prot;
				tmp_single_frame.qos = frame.qos;
				tmp_single_frame.region = frame.region;
				tmp_single_frame.delay = rand_data.delay;
				tmp_single_frame.delay_addrdata = rand_data.delay_addrdata;
				tmp_single_frame.last_one = FALSE;
				sem.get(1);
				this.addSingleFrame(tmp_single_frame);
				sem.put(1);
			end

			sem.get(1);
			this.frame_copy = frame; // keep the frame copy if recieved error repeat transaction
			this.ID = frame.id;
//			data_queue[data_queue.size -1].one_frame.last_one = TRUE;
			data_queue[data_queue.size -1].last_one = TRUE;
			data_queue[0].first_one = TRUE;

endfunction


function void axi_master_write_scheduler_packages::empyQueue();

	sem.get(1);
	while(data_queue.size())
		void'(data_queue.pop_front());

endfunction

function void axi_master_write_scheduler_packages::reincarnate();
   	$display("recreating burst with ID: %d", this.ID);
	this.empyQueue();
	this.addBurst(this.frame_copy);
endfunction

function void axi_master_write_scheduler_packages::resetErrorCounter();
	this.slave_error_counter = 0;
endfunction


function int axi_master_write_scheduler_packages::incrementErrorCounter();
	this.slave_error_counter++;
	return slave_error_counter;
endfunction

function int axi_master_write_scheduler_packages::getErrorCounter();
    return this.slave_error_counter;
endfunction


