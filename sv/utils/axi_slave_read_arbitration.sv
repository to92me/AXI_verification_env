// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_slave_read_arbitration.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : used by slave to determine which frame to send
*
* Classes :	axi_slave_read_arbitration
**/
// -----------------------------------------------------------------------------

`ifndef AXI_SLAVE_READ_ARBITRATION_SV
`define AXI_SLAVE_READ_ARBITRATION_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_read_arbitration
//
//------------------------------------------------------------------------------
/**
* Description : used by slave to determine which frame to send next
*
* Functions :	1. new (string name="axi_slave_read_arbitration",
*					uvm_component parent=null);
*				2. void build_phase(uvm_phase phase)
*				3. bit check_burst(axi_read_whole_burst whole_burst)
*
* Tasks :	1. get_new_burst(axi_read_whole_burst whole_burst)
*			2. get_new_single_frames(axi_read_whole_burst whole_burst)
*			3. dec_delay()
*			4. burst_complete(int burst_id)
*			5. get_single_frame(output axi_read_single_frame single_frame)
*			6. frame_complete(axi_read_single_frame rsp)
*			7. reset()
**/
// -----------------------------------------------------------------------------
class axi_slave_read_arbitration extends uvm_component;

	// fields
	axi_read_single_addr wait_queue[$];
	axi_read_single_addr ready_queue[$];
	axi_read_single_addr tmp_queue[$];
	axi_read_whole_burst burst_wait[$];
	bit [RID_WIDTH - 1 : 0] id_in_pipe[$];

	semaphore ready_sem, wait_sem, burst_sem, pipe_sem;

	// Configuration object
	axi_slave_config config_obj;

	// control bit to select whether early termination of bursts is supported
	bit terminate_enable = 1;
	// control bit to select whether to use the region signal TODO : AS DARKO COMMANDS
	bit region_enable = 1;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_slave_read_arbitration)
    	`uvm_field_int(terminate_enable, UVM_DEFAULT)
    	`uvm_field_int(region_enable, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name="axi_slave_read_arbitration", uvm_component parent=null);
		super.new(name, parent);
		ready_sem = new(1);
		wait_sem = new(1);
		burst_sem = new(1);
		pipe_sem = new(1);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task get_new_burst(axi_read_whole_burst whole_burst);
	extern virtual task get_new_single_frames(axi_read_whole_burst whole_burst);
	extern virtual task dec_delay();
	extern virtual task burst_complete(int burst_id);
	extern virtual task get_single_frame(output axi_read_single_frame single_frame);
	extern virtual function bit check_burst(axi_read_whole_burst whole_burst);
	extern virtual task frame_complete(axi_read_single_frame rsp);
	extern virtual task reset();

endclass : axi_slave_read_arbitration

//------------------------------------------------------------------------------
/**
* Function : build_phase
* Purpose : build - propagate the configuration object
* Parameters :	phase - uvm phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_arbitration::build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the configuration object
		if(!uvm_config_db#(axi_slave_config)::get(this, "", "axi_slave_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction : build_phase

//------------------------------------------------------------------------------
/**
* Task : get_new_burst
* Purpose : called when there is a new burst - first checks if the pipe is full
*			or if the id matches to another burst. If it does, the burst has to wait
* Inputs : whole_burst - burst request sent by master
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
/**
* Task : get_new_single_frames
* Purpose : put the single frames in the right queues - ready or wait, based
*			on delay and check if burst request is vaild
* Inputs :	whole_burst - burst request + queue of single frames
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_slave_read_arbitration::get_new_single_frames(axi_read_whole_burst whole_burst);

		axi_read_single_addr one_frame;
		axi_address_queue addr_queue;
		axi_address_calc addr_frame;
		bit slverr_flag = 0;

		// checks - if the request is not following protocol, return SLVERR
		slverr_flag = check_burst(whole_burst);

		// get all adresses and lane info. and put them in the queue
		if (!slverr_flag) begin
			addr_queue = new();
			addr_queue.calc_addr(whole_burst.addr, whole_burst.size, whole_burst.len, whole_burst.burst_type);
		end

		// for each single frame in burst
		for (int i = 0; i <= whole_burst.len; i++) begin
			// next frame
			one_frame = whole_burst.single_frames.pop_front();

			// get addr and byte lane info.
			if(!slverr_flag) begin
				addr_frame = addr_queue.pop_front();
				if (one_frame.correct_lane) begin
					one_frame.addr = addr_frame.addr;
					one_frame.upper_byte_lane = addr_frame.upper_byte_lane;
					one_frame.lower_byte_lane = addr_frame.lower_byte_lane;
				end
				if (one_frame.read_enable) begin
					// if the requested address is out of the slave range, return an error
					if (!(config_obj.check_addr_range(one_frame.addr + (one_frame.upper_byte_lane - one_frame.lower_byte_lane)))) begin
						slverr_flag = 1;
					end
				end
			end

			if(slverr_flag) begin
				one_frame.err = ERROR;
				one_frame.resp = SLVERR;
			end

			if(!terminate_enable)
				one_frame.err = NO_ERROR;	// so it doesn't complete the burst to early (in seq. lib)
			if(one_frame.last_mode == BAD_LAST_BIT) begin
				if (i == whole_burst.len) begin
					one_frame.err = ERROR;	// if the last bit for the last frame is not set
				end
			end

			// if there is no delay, put the frame in the ready queue
			if (one_frame.delay == 0) begin
				ready_sem.get(1);
				ready_queue.push_back(one_frame);
				ready_sem.put(1);
			end
			// if there is a delay put it in the wait queue
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

//------------------------------------------------------------------------------
/**
* Function : check_burst
* Purpose : check validity of the burst requeset and if the slave needs to
*			return an error
* Parameters :	whole_burst - burst info. beeing checked
* Return :	bit - flag (if set the slave should return SLVERR)
**/
//------------------------------------------------------------------------------
	function bit axi_slave_read_arbitration::check_burst(axi_read_whole_burst whole_burst);

		// cache
		if(whole_burst.cache[1] == 0)
			if(!(whole_burst.cache[3:2] == 0)) begin
				return 1;
			end

		// burst types and various rules
		case (whole_burst.burst_type)
			Reserved: begin
				return 1;
			end
			FIXED: begin
				if(whole_burst.len > 15) begin
					return 1;
				end
			end
			WRAP: begin
				// len can be 2, 4, 8, 16
				if(!(whole_burst.len inside {1, 3, 7, 15})) begin
					return 1;
				end
				// address must be aligned
				else if(!(whole_burst.addr == ($floor(whole_burst.addr/(2**whole_burst.size))*(2**whole_burst.size)))) begin
					return 1;
				end
			end
			INCR: begin
				if((whole_burst.len * (2**whole_burst.size)) >= 4096) begin
					return 1;
				end					
			end
		endcase

		// requested size is larger than DATA_WIDTH
		if(whole_burst.size > ($clog2(DATA_WIDTH / 8))) begin
			return 1;
		end

		// various rules for EXCLUSIVE request
		if(whole_burst.lock == EXCLUSIVE) begin
			// address must be aligned
			if(whole_burst.addr != ($floor(whole_burst.addr/(2**whole_burst.size))*(2**whole_burst.size))) begin
				return 1;
			end
			// the number of bytes must be a power of 2, max 128 bytes
			else if(!(((2**whole_burst.size) * whole_burst.len) inside {1, 3, 7, 15, 31, 63, 127})) begin
				return 1;
			end
			// burst length must not exceed 16 transfers
			else if(whole_burst.len > 15) begin
				return 1;
			end
			// TODO : za cache signale (str. 93)
		end

		// check region signal if needed
		if (region_enable && (whole_burst.region == 2)) begin 	// TODO : 2 ILI ?
			for (int i = 0; i <= whole_burst.len; i++) begin
				whole_burst.single_frames[i].read_enable = 0;	// don't read from memory
				whole_burst.single_frames[i].data = 0;	// return reset value
			end
		end
		
		return 0;	// no errors
		
	endfunction : check_burst

//------------------------------------------------------------------------------
/**
* Task : dec_delay
* Purpose : decrement delay and rearrange queues - if there is a frame with
*			0 delay in wait queue, move it to ready queue
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
/**
* Task : burst_complete
* Purpose : when burst is sent update the id_in_pipe queue and try to send
*			a burst from the burst_wait queue
* Inputs :	burst_id - id of the completed burst 
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
/**
* Task : get_single_frame
* Purpose : return the next ready frame (if there is none set FRAME_NOT_VALID)
*			and if needed, read from memory
* Inputs :
* Outputs : single_frame - next frame to be sent
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_slave_read_arbitration::get_single_frame(output axi_read_single_frame single_frame);

		axi_read_single_addr addr_frame;
		axi_address_calc addr_calc;

		// send frame, if there is one ready to be sent
		ready_sem.get(1);
		if (ready_queue.size()) begin
			addr_frame = ready_queue.pop_front();
			addr_frame.valid = FRAME_VALID;

			// read from memory - this is done here so that the correct value will be read
			if(addr_frame.read_enable && (addr_frame.resp != SLVERR)) begin
				addr_calc = new();
				addr_calc.addr = addr_frame.addr;
				addr_calc.upper_byte_lane = addr_frame.upper_byte_lane;
				addr_calc.lower_byte_lane = addr_frame.lower_byte_lane;
				addr_calc.readMemory(config_obj, addr_frame.data);
			end
		end
		else begin
			addr_frame = axi_read_single_addr::type_id::create("addr_frame");
			addr_frame.valid = FRAME_NOT_VALID;
		end
		ready_sem.put(1);

		single_frame = addr_frame;

	endtask : get_single_frame

//------------------------------------------------------------------------------
/**
* Task : reset
* Purpose : empty all queues
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_slave_read_arbitration::reset();
		`uvm_info(get_type_name(), $sformatf("Reset"), UVM_LOW);

		ready_sem.get(1);
		ready_queue.delete();
		ready_sem.put(1);

		wait_sem.get(1);
		wait_queue.delete();
		wait_sem.put(1);

		burst_sem.get(1);
		burst_wait.delete();
		burst_sem.put(1);

		pipe_sem.get(1);
		id_in_pipe.delete();
		pipe_sem.put(1);

	endtask : reset

//------------------------------------------------------------------------------
/**
* Task : frame_complete
* Purpose : called when the seq. finishes sending a frame; burst completness is
*			checked and delay decremented
* Inputs : rsp - single frame that has been sent
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_slave_read_arbitration::frame_complete(axi_read_single_frame rsp);
		// check if burst is complete
		// if err is set - early termination or bad last bit for last frame
		// or if last bit was sent
		if((rsp.valid == FRAME_VALID) && (rsp.id_mode == GOOD_ID)) begin
			if((rsp.err == ERROR) || ((rsp.last_mode == GOOD_LAST_BIT) && (rsp.last))) begin
				burst_complete(rsp.id);
			end
		end

		// decrement delay and update the queues
		dec_delay();
	endtask : frame_complete

`endif