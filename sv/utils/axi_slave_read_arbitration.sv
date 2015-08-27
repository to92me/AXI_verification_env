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
	axi_read_single_addr wait_queue[$];
	axi_read_single_addr ready_queue[$];
	axi_read_single_addr tmp_queue[$];
	axi_read_whole_burst burst_wait[$];
	bit [ID_WIDTH - 1 : 0] id_in_pipe[$];

	semaphore ready_sem, wait_sem, burst_sem, pipe_sem;

	// Configuration object
	axi_slave_config config_obj;

	// control bit to select whether or not to read from memory
	bit read_enable = 1;
	// control bit to select whether early termination of bursts is supported
	bit terminate_enable = 1;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_slave_read_arbitration)
    	`uvm_field_int(read_enable, UVM_DEFAULT)
    	`uvm_field_int(terminate_enable, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name="axi_slave_read_arbitration", uvm_component parent=null);
		super.new(name, parent);
		ready_sem = new(1);
		wait_sem = new(1);
		burst_sem = new(1);
		pipe_sem = new(1);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the configuration object
		if(!uvm_config_db#(axi_slave_config)::get(this, "", "axi_slave_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction : build_phase

	extern virtual task get_new_burst(axi_read_whole_burst whole_burst);
	extern virtual task get_new_single_frames(axi_read_whole_burst whole_burst);
	extern virtual task dec_delay();
	extern virtual task burst_complete(int burst_id);
	extern virtual task get_single_frame(output axi_read_single_frame single_frame);

endclass : axi_slave_read_arbitration

	// called when there is a new burst - first checks if the pipe is full
	// or if the id matches to another burst. If it does, the burst has to wait
	task axi_slave_read_arbitration::get_new_burst(axi_read_whole_burst whole_burst);
		pipe_sem.get(1);

		// check if pipe is full
		if (id_in_pipe.size() == SLAVE_PIPE_SIZE) begin
			burst_wait.push_back(whole_burst);
			pipe_sem.put(1);
			return;
		end

		// check if there is already a burst with that id
		foreach (id_in_pipe[i])
			if (whole_burst.id == id_in_pipe[i]) begin
				burst_wait.push_back(whole_burst);
				pipe_sem.put(1);
				return;
			end

		// if not it can be sent
		id_in_pipe.push_back(whole_burst.id);
		pipe_sem.put(1);
		get_new_single_frames(whole_burst);

	endtask : get_new_burst

	// put the single frames in the right queues - ready or wait, based on delay
	task axi_slave_read_arbitration::get_new_single_frames(axi_read_whole_burst whole_burst);

		axi_read_single_addr one_frame;
		axi_address_queue addr_queue;
		axi_address_calc addr_frame;

		// get all adresses
		if (read_enable) begin
			if (whole_burst.burst_type != Reserved) begin
				addr_queue = new();
				addr_queue.calc_addr(whole_burst.addr, whole_burst.size, whole_burst.len, whole_burst.burst_type);
			end
			else
				// PITAJ DARKA
				`uvm_fatal("MODE_ERR",{"cannot use Reserved burst type"});
		end

		for (int i = 0; i <= whole_burst.len; i++) begin

			one_frame = axi_read_single_addr::type_id::create("one_frame",this);
			one_frame.copy(whole_burst.single_frames.pop_front());

			// if requested size is larger than DATA_WIDTH, return an error
			if(whole_burst.size <= ($clog2(DATA_WIDTH / 8))) begin
				one_frame.resp = SLVERR;
				one_frame.err = ERROR;
			end

			// get addr and byte lane info.
			if (read_enable) begin
				addr_frame = addr_queue.pop_front();
				one_frame.addr_calc.addr = addr_frame.addr;
				one_frame.addr_calc.upper_byte_lane = addr_frame.upper_byte_lane;
				one_frame.addr_calc.lower_byte_lane = addr_frame.lower_byte_lane;

				if (!(config_obj.check_addr_range(one_frame.addr_calc.addr - (one_frame.addr_calc.upper_byte_lane - one_frame.addr_calc.lower_byte_lane + 1)))) begin
					// if the highest requested address is not in the address range of the
					// given slave, return SLVERR TODO : PITAJ DARKA
					one_frame.resp = SLVERR;
					one_frame.err = ERROR;
				end
			end

			if(!terminate_enable)
				one_frame.err = NO_ERROR;	// so it doesn't complete the burst to early (in seq. lib)
			if(one_frame.last_mode == BAD_LAST_BIT) begin
				if (i == whole_burst.len) begin
					one_frame.err = ERROR;	// if the last bit for the last frame is not set
				end
			end

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

			// if there is an error kill the burst
			if (terminate_enable && (one_frame.err == ERROR)) begin
				break;
			end
		end
	endtask : get_new_single_frames

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

	// return the next ready frame (if there is none set FRAME_NOT_VALID)
	// and if needed, read from memory
	task axi_slave_read_arbitration::get_single_frame(output axi_read_single_frame single_frame);

		axi_read_single_addr addr_frame;
		axi_address_calc addr_calc;

		// send frame, if there is one ready to be sent
		ready_sem.get(1);
		if (ready_queue.size()) begin
			addr_frame = ready_queue.pop_front();
			addr_frame.valid = FRAME_VALID;

			// read from memory - this is done here so that the correct value will be read
			if(read_enable && (addr_frame.resp != SLVERR)) begin
				addr_calc = new();
				/*addr_calc.addr = addr_frame.addr;
				addr_calc.upper_byte_lane = addr_frame.upper_byte_lane;
				addr_calc.lower_byte_lane = addr_frame.lower_byte_lane;*/
				addr_calc = addr_frame.addr_calc;
				addr_calc.readMemory(config_obj, addr_frame.data);
			end
		end
		else begin
			addr_frame = axi_read_single_addr::type_id::create("addr_frame");
			addr_frame.valid = FRAME_NOT_VALID;
		end
		ready_sem.put(1);

		single_frame = addr_frame;

	endtask

`endif