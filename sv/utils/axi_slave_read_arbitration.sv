/******************************************************************************
	* DVT CODE TEMPLATE: component
	* Created by root on Aug 5, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_read_arbitration
//
//------------------------------------------------------------------------------

class axi_slave_read_arbitration extends uvm_component;

	// fields
	axi_read_single_frame one_frame;
	axi_read_single_frame wait_queue[$];
	axi_read_single_frame ready_queue[$];
	axi_read_single_frame tmp_queue[$];

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_slave_read_arbitration)
    	`uvm_field_object(one_frame, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name="axi_slave_read_arbit", uvm_component parent=null);
		super.new(name, parent);
		one_frame = new();
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	// get burst information
	function void get_new_burst(ref axi_frame burst_frame);
		for (int i=0; i<burst_frame.len; i++) begin
			one_frame = axi_read_single_frame::type_id::create("one_frame",this);
			assert (one_frame.randomize())
			one_frame.id = burst_frame.id;
			one_frame.lock = burst_frame.lock;
			if (i == burst_frame.len-1)
				one_frame.last = 1;
			else
				one_frame.last = 0;

			if (one_frame.delay == 0)
				ready_queue.push_back(one_frame);
			else
				wait_queue.push_front(one_frame);
		end
	endfunction : get_new_burst

	// decrement delay and rearrange queues
	function void slave_read_dec_delay();
		for (int i=0; i<wait_queue.size(); i++) begin
			wait_queue[i].delay--;
			if (!wait_queue[i].delay)
				ready_queue.push_back(wait_queue[i]);
			else
				tmp_queue.push_back(wait_queue[i]);
		end

		wait_queue.delete();
		foreach (tmp_queue[i])
			wait_queue.push_back(tmp_queue[i]);
		tmp_queue.delete();

	endfunction : slave_read_dec_delay

endclass : axi_slave_read_arbitration
