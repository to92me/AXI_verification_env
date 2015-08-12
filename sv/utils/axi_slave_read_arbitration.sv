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

	axi_frame_base burst_wait[$];

	semaphore ready_sem, wait_sem, burst_sem;

	// if next burst has the same id, it must wait for the previous one to be sent
	int id_flag = 0;

	// delay value of previous frame in burst
	int previous_delay = 0;

	// Configuration object
	axi_slave_config config_obj;


	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_slave_read_arbitration)
    	`uvm_field_object(one_frame, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name="axi_slave_read_arbit", uvm_component parent=null);
		super.new(name, parent);
		one_frame = new();
		ready_sem = new(1);
		wait_sem = new(1);
		burst_sem = new(1);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the configuration object
		if(!uvm_config_db#(axi_slave_config)::get(this, "", "config_obj", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction : build_phase

	extern virtual task get_new_burst(axi_frame_base burst_frame);
	extern virtual task create_single_frames(axi_frame_base burst_frame);
	extern virtual task dec_delay();

endclass : axi_slave_read_arbitration

	// get burst information
	task axi_slave_read_arbitration::get_new_burst(axi_frame_base burst_frame);

		wait_sem.get(1);
		burst_sem.get(1);

		foreach (wait_queue[i])
			if (burst_frame.id == wait_queue[i].id) begin
				burst_wait.push_back(burst_frame);
				id_flag = 1;
			end

		if (!id_flag)
			foreach (ready_queue[i])
				if (burst_frame.id == ready_queue[i].id) begin
					burst_wait.push_back(burst_frame);
					id_flag = 1;
				end
		wait_sem.put(1);
		burst_sem.put(1);

		// new burst doesn't have the same id, create all single frames for it
		if (!id_flag) begin
			id_flag = 0;
			create_single_frames(burst_frame);
		end

	endtask : get_new_burst

	task axi_slave_read_arbitration::create_single_frames(axi_frame_base burst_frame);

		previous_delay = 0;

		wait_sem.get(1);
		ready_sem.get(1);

	    for (int i=0; i<burst_frame.len; i++) begin
			one_frame = axi_read_single_frame::type_id::create("one_frame",this);
			assert (one_frame.randomize() with {delay >= previous_delay;})
			previous_delay = one_frame.delay;
			one_frame.id = burst_frame.id;
			if ((burst_frame.lock == EXCLUSIVE) && (config_obj.lock == NORMAL))
				one_frame.resp = OKAY;
			else if (burst_frame.lock == EXCLUSIVE)
				one_frame.resp = EXOKAY;
			else
				one_frame.resp = OKAY;

			if (i == burst_frame.len-1)
				one_frame.last = 1;
			else
				one_frame.last = 0;
			if (one_frame.last_mode == BAD_LAST_BIT)
				one_frame.last = ~one_frame.last;

			if (one_frame.delay == 0)
				ready_queue.push_back(one_frame);
			else
				wait_queue.push_back(one_frame);
		end
		wait_sem.put(1);
	    ready_sem.put(1);

	endtask : create_single_frames

	// decrement delay and rearrange queues
	task axi_slave_read_arbitration::dec_delay();

		wait_sem.get(1);

		for (int i=0; i<wait_queue.size(); i++) begin
			wait_queue[i].delay--;
			if (!wait_queue[i].delay) begin
				ready_sem.get(1);
				ready_queue.push_back(wait_queue[i]);
				ready_sem.put(1);
			end
			else
				tmp_queue.push_back(wait_queue[i]);
		end

		wait_queue = tmp_queue;
		tmp_queue.delete();

		wait_sem.put(1);

	endtask : dec_delay
