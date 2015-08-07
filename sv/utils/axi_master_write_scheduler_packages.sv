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


class axi_master_write_scheduler_packages;

	axi_single_frame data_queue[$]; // MENJAO
	axi_single_frame one_frame;
	axi_mssg mssg;
	int items_in_queue = 0;
	bit [ID_WIDTH-1 : 0] queu_id;
	burst_queue_lock_enum lock_state = QUEUE_LOCKED;

	function new ();
		one_frame = new();
	endfunction : new


	extern function axi_mssg getNextSingleFrame();
	extern function void decrementDelay();
	extern function void addSingleFrame(input axi_single_frame frame_for_push);


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
	if (one_frame.delay != 0)
		one_frame.delay--;
	data_queue.push_front(one_frame);
endfunction: decrementDelay

function void axi_master_write_scheduler_packages::addSingleFrame(input axi_single_frame frame_for_push);
	$write(" added data to queu");
	items_in_queue++;
    data_queue.push_front(frame_for_push);
endfunction
