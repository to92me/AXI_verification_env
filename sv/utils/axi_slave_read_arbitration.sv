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

`ifndef AXI_SLAVE_READ_ARBITRATION_SV
`define AXI_SLAVE_READ_ARBITRATION_SV

class axi_slave_read_arbitration extends uvm_component;

	// fields
	axi_read_single_frame one_frame;
	axi_read_single_frame wait_queue[$];
	axi_read_single_frame ready_queue[$];
	axi_read_single_frame tmp_queue[$];
	axi_read_burst_frame burst_wait[$];
	bit [ID_WIDTH - 1 : 0] id_in_pipe[$];

	semaphore ready_sem, wait_sem, burst_sem, pipe_sem;

	// delay value of previous frame in burst
	int previous_delay = 0;

	// Configuration object
	axi_slave_config config_obj;


	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_slave_read_arbitration)
    	`uvm_field_object(one_frame, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name="axi_slave_read_arbitration", uvm_component parent=null);
		super.new(name, parent);
		one_frame = new();
		ready_sem = new(1);
		wait_sem = new(1);
		burst_sem = new(1);
		pipe_sem = new(1);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the configuration object
		if(!uvm_config_db#(axi_slave_config)::get(this, "", "config_obj", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction : build_phase

	extern virtual task get_new_burst(axi_read_burst_frame burst_frame);
	extern virtual task create_single_frames(axi_read_burst_frame burst_frame);
	extern virtual task dec_delay();
	extern virtual task burst_complete(int burst_id);
	extern virtual task get_single_frame(ref axi_read_single_frame single_frame);

endclass : axi_slave_read_arbitration

	// called when there is a new burst - first checks if the pipe is full
	// or if the id matches to another burst. If it does, the burst has to wait
	// otherwise all the single frames are created
	task axi_slave_read_arbitration::get_new_burst(axi_read_burst_frame burst_frame);
		pipe_sem.get(1);

		// check if pipe is full
		if (id_in_pipe.size() == PIPE_SIZE) begin
			burst_wait.push_back(burst_frame);
			pipe_sem.put(1);
			return;
		end

		// check if there is already a burst with that id
		foreach (id_in_pipe[i])
			if (burst_frame.id == id_in_pipe[i]) begin
				burst_wait.push_back(burst_frame);
				pipe_sem.put(1);
				return;
			end

		// if not, create all single frames
		id_in_pipe.push_back(burst_frame.id);
		pipe_sem.put(1);
		create_single_frames(burst_frame);

	endtask : get_new_burst

	// based on burst info., create all the single frames and put them in the
	// right queues - ready or wait, based on delay
	task axi_slave_read_arbitration::create_single_frames(axi_read_burst_frame burst_frame);

		previous_delay = 0;

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

			if (one_frame.delay == 0) begin
				ready_sem.get(1);
				ready_queue.push_back(one_frame);
				ready_sem.put(1);
			end
			else begin
				wait_sem.get(1);
				wait_queue.push_back(one_frame);
				wait_sem.put(1);
			end
		end
	endtask : create_single_frames

	// decrement delay and rearrange queues - if there is a frame
	// with 0 delay in wait queue, move it to ready queue
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

	// when burst is sent update the id_in_pipe queue and try to send
	// a burst from the burst_wait queue
	task axi_slave_read_arbitration::burst_complete(input int burst_id);
		int i, tmp, tmp1;

		// remove it from the pipe
	    pipe_sem.get(1);
		for (i=0; i<id_in_pipe.size(); i++) begin
			if (burst_id == id_in_pipe[i])
				break;
			end
		id_in_pipe.delete(i);
		pipe_sem.put(1);

		// if there is a burst waiting
		burst_sem.get(1);
		tmp = burst_wait.size();
		tmp1 = tmp;
		while (tmp) begin
			get_new_burst(burst_wait.pop_front());
			// check if burst was sent - maybe it has the same id
			// so it must wait again, then try to send the next one
			if (tmp1 != burst_wait.size())
				tmp = 0;
			else begin
				// when all the bursts have been checked, exit loop
				tmp--;
			end
		end
		burst_sem.put(1);
	endtask

	task axi_slave_read_arbitration::get_single_frame(ref axi_read_single_frame single_frame);
		// send frame, if there is one ready to be sent
		ready_sem.get(1);
		if (ready_queue.size()) begin
			single_frame = ready_queue.pop_front();
			single_frame.valid = FRAME_VALID;
		end
		else begin
			single_frame.valid = FRAME_NOT_VALID;
		end
		ready_sem.put(1);

	endtask

`endif