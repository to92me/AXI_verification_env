/******************************************************************************
* DVT CODE TEMPLATE: sequence library
* Created by root on Aug 4, 2015
* uvc_company = uvc_company, axi_slave_read = axi_slave_read
* uvc_trans = uvc_trans
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_axi_slave_read_base_seq
//
//------------------------------------------------------------------------------
// This sequence raises/drops objections in the pre/post_body so that root
// sequences raise objections but subsequences do not.
class axi_slave_read_base_sequence extends uvm_sequence #(axi_read_base_frame);

	axi_read_whole_burst req;
	axi_read_single_frame rsp;

	`uvm_object_utils(axi_slave_read_base_sequence)

	`uvm_declare_p_sequencer(axi_slave_read_sequencer)

	// new - constructor
	function new(string name="axi_slave_read_base_sequence");
		super.new(name);
	endfunction
/*
	// Raise in pre_body so the objection is only raised for root sequences.
	// There is no need to raise for sub-sequences since the root sequence
	// will encapsulate the sub-sequence.
	virtual task pre_body();
		if (starting_phase!=null) begin
			starting_phase.raise_objection(this);
		end
	endtask

	// Drop the objection in the post_body so the objection is removed when
	// the root sequence is complete.
	virtual task post_body();
		if (starting_phase!=null) begin
			starting_phase.drop_objection(this);
		end
	endtask
*/
endclass : axi_slave_read_base_sequence

//------------------------------------------------------------------------------
//
// SEQUENCE: axi_slave_read_simple_two_phase_seq
//
//------------------------------------------------------------------------------
class axi_slave_read_simple_two_phase_seq extends axi_slave_read_base_sequence;

	axi_read_single_frame one_frame;

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
				for (int i = 0; i < req.len; i++) begin
					one_frame = axi_read_single_frame::type_id::create("one_frame");

					assert (one_frame.randomize() with {delay >= previous_delay;})
					previous_delay = one_frame.delay;

					one_frame.id = req.id;
					calc_resp(one_frame, p_sequencer.config_obj.lock, req.lock);
					one_frame.last = calc_last_bit((i == req.len-1), one_frame.last_mode);

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

			// check if burst is complete
			if ((rsp.valid == FRAME_VALID) && ((rsp.last == rsp.last_mode) || (rsp.err == ERROR))) begin
				p_sequencer.arbit.burst_complete(rsp.id);
			end

			// decrement delay and update the queues
			p_sequencer.arbit.dec_delay();
		end

	endtask


	// TODO : premesti u axi_read_frames
	function void calc_resp(ref axi_read_single_frame one_frame, lock_enum slave_lock, lock_enum burst_lock);
		if ((burst_lock == EXCLUSIVE) && (slave_lock == NORMAL)) begin
			one_frame.resp = OKAY;
			one_frame.err = ERROR;
		end
		else if (burst_lock == EXCLUSIVE) begin
			one_frame.resp = EXOKAY;
			one_frame.err = NO_ERROR;
		end
		else begin
			one_frame.resp = OKAY;
			one_frame.err = NO_ERROR;
		end
	endfunction : calc_resp

	function bit calc_last_bit(bit last, last_enum mode);
		if(mode == BAD_LAST_BIT)
			return ~last;
		else
			return last;
	endfunction : calc_last_bit


endclass : axi_slave_read_simple_two_phase_seq
