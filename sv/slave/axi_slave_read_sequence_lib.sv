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
virtual class axi_slave_read_base_sequence extends uvm_sequence #(axi_frame);

	axi_frame req;
	axi_frame util_transfer;

	`uvm_object_utils(axi_slave_read_base_sequence)
	`uvm_declare_p_sequencer(axi_slave_read_sequncer)

	// new - constructor
	function new(string name="axi_slave_read_base_seq");
		super.new(name);
	endfunction

	// Raise in pre_body so the objection is only raised for root sequences.
	// There is no need to raise for sub-sequences since the root sequence
	// will encapsulate the sub-sequence.
	virtual task pre_body();
		if (starting_phase!=null) begin
			`uvm_info(get_type_name(),
				$sformatf("!s! pre_body() raising !s! objection",
					get_sequence_path(),
					starting_phase.get_name()), UVM_MEDIUM);
			starting_phase.raise_objection(this);
		end
	endtask

	// Drop the objection in the post_body so the objection is removed when
	// the root sequence is complete.
	virtual task post_body();
		if (starting_phase!=null) begin
			`uvm_info(get_type_name(),
				$sformatf("!s! post_body() dropping !s! objection",
					get_sequence_path(),
					starting_phase.get_name()), UVM_MEDIUM);
			starting_phase.drop_objection(this);
		end
	endtask

endclass : axi_slave_read_base_sequence

//------------------------------------------------------------------------------
//
// SEQUENCE: axi_slave_read_transfer_seq
//
//------------------------------------------------------------------------------
class axi_slave_read_transfer_seq extends axi_slave_read_base_sequence;

	`uvm_object_utils(axi_slave_read_transfer_seq)

	// new - constructor
	function new(string name="axi_slave_read_transfer_seq");
		super.new(name);
	endfunction

	virtual task body();
		forever	begin
			p_sequencer.addr_trans_port.peek(util_transfer);
			if(p_sequencer.config_obj.check_addr_range(util_transfer.addr)) begin
				`uvm_do_with(reg,
					{ req.addr = util_transfer.addr;
						req.id == util_transfer.id;
						req.burst_type == util_transfer.burst_type;
						req.cache == util_transfer.cache;
						req.len == util_transfer.len;
						req.size == util_transfer.size;
						req.lock == util_transfer.lock;
						req.qos == util_transfer.qos;
						req.prot == util_transfer.prot;
						req.region == util_transfer.region;
						})
				get_response(rsp);
			end
		end
	endtask

endclass : axi_slave_read_transfer_seq