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

	// Add local random fields and constraints here

	`uvm_object_utils(axi_master_read_transfer_seq)

	// new - constructor
	function new(string name="axi_master_read_transfer_seq");
		super.new(name);
	endfunction

	virtual task body();
		axi_read_burst_frame error_bursts[$];
		int i, flag;

		// two threads - one for sending to the driver
		// and one for getting responses
		fork
			begin
				repeat(3) begin
					`uvm_do_with(req, {req.valid == FRAME_VALID;})
				end

				begin
					if (error_bursts.size()) begin
						// send it again, no randomization
						req = error_bursts.pop_front();
						start_item(req);
						finish_item(req);
						// if there is an error once, the burst will be sent again
						// but if there is an error again, it will not be sent again
					end
				end

			end

			forever begin
				get_response(rsp);
				if (rsp.valid == FRAME_NOT_VALID) begin
					error_bursts.push_back(rsp);
				end
				else begin
					flag = 0;
					for (i = 0; i < error_bursts.size(); i++)
						if (error_bursts[i] == rsp)
							flag = 1;
					if (flag)
						error_bursts.delete(i);
				end
			end
		join_any

/*		begin
		i = error_bursts.size();
		while (i--) begin
			// send it again, no randomization
			req = error_bursts.pop_front();
			start_item(req);
			finish_item(req);
			// if there is an error once, the burst will be sent again
			// but if there is an error again, it will not be sent again
		end
		end*/
	endtask

endclass : axi_master_read_transfer_seq
