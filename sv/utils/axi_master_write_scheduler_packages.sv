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

	axi_data data_queue[$];
	axi_data one_frame;
	axi_mssg mssg;

	function new ();
		one_frame = new();
	endfunction : new


	extern function axi_mssg getNextSingleFrame();
	extern function void axi_decrement_delay();


endclass : axi_master_write_scheduler_packages



function axi_mssg axi_master_write_scheduler_packages::getNextSingleFrame();
	mssg = new();
	one_frame = data_queue.pop_front;
	if (one_frame.delay == 0)
		begin
		mssg.state = axi_mssg_enum::READY;
		mssg.data = one_frame.data;
		end
	else
		begin
		mssg.state = axi_mssg_enum::NOT_READY;
		data_queue.push_front(one_frame);
		end
endfunction


function axi_master_write_scheduler_packages::axi_decrement_delay();
	one_frame = data_queue.pop_front;
	if (one_frame.delay != 0)
		one_frame.delay--;
	data_queue.push_front(one_frame);
endfunction: axi_decrement_delay