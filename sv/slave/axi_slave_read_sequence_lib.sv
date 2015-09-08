// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_slave_read_sequence_lib.sv
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
* Description : sequences for slave sequencer
*
* Classes :	1. axi_slave_read_base_sequence
*			2. axi_slave_read_simple_two_phase_seq
*			3. axi_slave_read_random_delay
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_read_base_sequence
//
//------------------------------------------------------------------------------
/**
* Description : base sequence, declares sequencer; it does not raise/drop
*				objections (that is done it the master)
*
* Functions :	1. new(string name="axi_slave_read_base_sequence")
**/
// -----------------------------------------------------------------------------
class axi_slave_read_base_sequence extends uvm_sequence #(axi_read_base_frame);

	axi_read_whole_burst req;
	axi_read_single_frame rsp;

	`uvm_object_utils(axi_slave_read_base_sequence)

	`uvm_declare_p_sequencer(axi_slave_read_sequencer)

	// new - constructor
	function new(string name="axi_slave_read_base_sequence");
		super.new(name);
	endfunction
	
endclass : axi_slave_read_base_sequence

//------------------------------------------------------------------------------
//
// SEQUENCE: axi_slave_read_simple_two_phase_seq
//
//------------------------------------------------------------------------------
/**
* Description : sequence with 2 phases:
*					- request sent to driver which returns with burst info.
*					- single frame sent to driver
*
* Functions :	1. new(string name="axi_master_read_multiple_addr")
*
* Tasks :	1. body()
**/
// -----------------------------------------------------------------------------
class axi_slave_read_simple_two_phase_seq extends axi_slave_read_base_sequence;

	axi_read_single_addr one_frame;

	`uvm_object_utils(axi_slave_read_simple_two_phase_seq)

	// new - constructor
	function new(string name="axi_slave_read_simple_two_phase_seq");
		super.new(name);
	endfunction

	virtual task body();

		int previous_delay;

		forever begin
			req = axi_read_whole_burst::type_id::create("req");
			rsp = axi_read_single_frame::type_id::create("rsp");

			// request burst from driver
			start_item(req);
			finish_item(req);

			// if there is a new burst
			// randomize single frames
			if (req.valid == FRAME_VALID) begin
				previous_delay = 0;

				for (int i = 0; i <= req.len; i++) begin
					one_frame = axi_read_single_addr::type_id::create("one_frame");

					assert (one_frame.randomize() with {delay >= previous_delay;})
					previous_delay = one_frame.delay;

					// get id, resp and last
					one_frame.get_id(one_frame.id_mode, req.id);
					one_frame.calc_resp(p_sequencer.config_obj.lock, req.lock, one_frame.resp_mode);
					one_frame.last = one_frame.calc_last_bit((i == req.len), one_frame.last_mode);

					// store that single frame in the queue
					req.single_frames.push_back(one_frame);
				end

				// send burst info (and the single frames) to arbitration
				p_sequencer.arbit.get_new_burst(req);
			end

			// get single frame to send to driver
			p_sequencer.arbit.get_single_frame(rsp);

			// response - send single frame to driver
			start_item(rsp);
			finish_item(rsp);

			// send item to seq. to check for burst completeness and to decrement delay
			p_sequencer.arbit.frame_complete(rsp);

			// check for reset
			if(rsp.status == UVM_TLM_INCOMPLETE_RESPONSE) begin
				p_sequencer.arbit.reset();
			end

		end

	endtask

endclass : axi_slave_read_simple_two_phase_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: axi_slave_read_random_delay
//
//------------------------------------------------------------------------------
/**
* Description : sequence with 2 phases:
*					- request sent to driver which returns with burst info.
*					- single frame sent to driver, all frames have 0 delay
*				delay is totaly random
*
* Functions :	1. new(string name="axi_slave_read_random_delay")
*
* Tasks :	1. body()
**/
// -----------------------------------------------------------------------------
class axi_slave_read_random_delay extends axi_slave_read_base_sequence;

	axi_read_single_addr one_frame;

	`uvm_object_utils(axi_slave_read_random_delay)

	// new - constructor
	function new(string name="axi_slave_read_random_delay");
		super.new(name);
	endfunction

	virtual task body();

		forever begin
			req = axi_read_whole_burst::type_id::create("req");
			rsp = axi_read_single_frame::type_id::create("rsp");

			// request burst from driver
			start_item(req);
			finish_item(req);

			// if there is a new burst
			// randomize single frames
			if (req.valid == FRAME_VALID) begin
				for (int i = 0; i <= req.len; i++) begin
					one_frame = axi_read_single_addr::type_id::create("one_frame");

					assert (one_frame.randomize())

					// get id, resp and last
					one_frame.get_id(one_frame.id_mode, req.id);
					one_frame.calc_resp(p_sequencer.config_obj.lock, req.lock, one_frame.resp_mode);
					one_frame.last = one_frame.calc_last_bit((i == req.len), one_frame.last_mode);

					// store that single frame in the queue
					req.single_frames.push_back(one_frame);
				end

				// send burst info (and the single frames) to arbitration
				p_sequencer.arbit.get_new_burst(req);
			end

			// get single frame to send to driver
			p_sequencer.arbit.get_single_frame(rsp);

			// response - send single frame to driver
			start_item(rsp);
			finish_item(rsp);

			// send item to seq. to check for burst completeness and to decrement delay
			p_sequencer.arbit.frame_complete(rsp);

			// check for reset
			if(rsp.status == UVM_TLM_INCOMPLETE_RESPONSE) begin
				p_sequencer.arbit.reset();
			end

		end

	endtask

endclass : axi_slave_read_random_delay