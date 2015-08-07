/******************************************************************************
* DVT CODE TEMPLATE: sequence library
* Created by root on Aug 4, 2015
* uvc_company = uvc_company, uvc_name = uvc_name
* axi_frame = axi_frame
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_base_seq
//
//------------------------------------------------------------------------------
// This sequence raises/drops objections in the pre/post_body so that root
// sequences raise objections but subsequences do not.
virtual class axi_master_read_base_seq extends uvm_sequence #(axi_frame);

	// TODO: Add fields here


	`uvm_object_utils(axi_master_read_base_sequence)
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
		`uvm_do(req)
		get_response(rsp);
	endtask

endclass : axi_master_read_transfer_seq
