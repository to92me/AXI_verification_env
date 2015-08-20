/******************************************************************************
* DVT CODE TEMPLATE: sequence library
* Created by root on Aug 4, 2015
* uvc_company = uvc_company, uvc_name = uvc_name
* axi_read_burst_frame = axi_read_burst_frame
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_base_seq
//
//------------------------------------------------------------------------------
// This sequence raises/drops objections in the pre/post_body so that root
// sequences raise objections but subsequences do not.
class axi_master_read_base_seq extends uvm_sequence #(axi_read_burst_frame);

	`uvm_object_utils(axi_master_read_base_seq)
	`uvm_declare_p_sequencer(axi_master_read_sequencer)

	// new - constructor
	function new(string name="uvc_name_base_seq");
		super.new(name);
	endfunction

	// Raise in pre_body so the objection is only raised for root sequences.
	// There is no need to raise for sub-sequences since the root sequence
	// will encapsulate the sub-sequence.
	virtual task pre_body();
		if (starting_phase!=null) begin
			starting_phase.raise_objection(this);
			//uvm_test_done.set_drain_time(this, 200ns);
		end
	endtask

	// Drop the objection in the post_body so the objection is removed when
	// the root sequence is complete.
	virtual task post_body();
		if (starting_phase!=null) begin
			starting_phase.drop_objection(this);
		end
	endtask

endclass : axi_master_read_base_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: axi_master_read_transfer_seq
//
//------------------------------------------------------------------------------
class axi_master_read_transfer_seq extends axi_master_read_base_seq;

	`uvm_object_utils(axi_master_read_transfer_seq)

	int count = 0;
	int num_of_err = 0;
	axi_read_burst_frame error_bursts[$];	// a queue for holding bursts that returned an error

	rand bit[ADDR_WIDTH-1 : 0] addr_rand;

	// new - constructor
	function new(string name="axi_master_read_transfer_seq");
		super.new(name);
	endfunction

	virtual task body();

		use_response_handler(1);

		count = 3;	// number of bursts to be sent

		repeat(3) begin
			`uvm_do_with(req, {req.valid == FRAME_VALID; req.addr == addr_rand;})
		end

		// after sending all frames, check if there was an error
		// and send that burst request again
/*		fork
		begin
			if (num_of_err) begin
				count++;	// increase number of bursts waiting for response
				req = error_bursts.pop_front();
				num_of_err--;
				// send it again, no randomization
				start_item(req);
				finish_item(req);
				// if there is an error once, the burst will be sent again
				// but if there is an error again, it will not be sent again
			end
			end
		join_none*/

		wait(!count);	// wait for all responses before finishing simulation

		// if there was an error, send those frames again
		num_of_err = error_bursts.size();
		count = num_of_err;
		while (num_of_err--) begin
			req = error_bursts.pop_front();
			// send it again, no randomization
			start_item(req);
			finish_item(req);
			// if there is an error once, the burst will be sent again
			// but if there is an error again, it will not be sent again
		end

		wait(!count);

	endtask

	// this is called by the sequencer for each response that arrives for this sequence
	virtual function void response_handler(uvm_sequence_item response);

				if(!($cast(rsp, response)))
					`uvm_error("CASTFAIL", "The recieved response item is not a burst frame");

				count--;	// keep track of number of responses

				// if there was an error put the burst in the error queue so it will be sent agian
				if (rsp.valid == FRAME_NOT_VALID) begin
					error_bursts.push_back(rsp);
				end

	endfunction: response_handler

endclass : axi_master_read_transfer_seq
