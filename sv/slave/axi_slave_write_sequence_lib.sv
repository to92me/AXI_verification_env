/******************************************************************************
* DVT CODE TEMPLATE: sequence library
* Created by root on Aug 2, 2015
* uvc_company = uvc_company, uvc_name = uvc_name
* uvc_trans = uvc_trans 
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_base_seq
//
//------------------------------------------------------------------------------
// This sequence raises/drops objections in the pre/post_body so that root
// sequences raise objections but subsequences do not.
virtual class uvc_name_base_sequence extends uvm_sequence #(uvc_trans);

	// TODO: Add fields here
	

	// new - constructor
	function new(string name="uvc_name_base_seq");
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

endclass : uvc_name_base_sequence

//------------------------------------------------------------------------------
//
// SEQUENCE: uvc_name_transfer_seq
//
//------------------------------------------------------------------------------
class uvc_name_transfer_seq extends uvc_name_base_sequence;
	
	// Add local random fields and constraints here
		
	`uvm_object_utils(uvc_name_transfer_seq)
	
	// new - constructor
	function new(string name="uvc_name_transfer_seq");
		super.new(name);
	endfunction

	virtual task body();
		`uvm_do_with(req, 
			{ /* TODO : add constraints here*/ } )
			`uvm_do_w
		get_response(rsp);
	endtask

endclass : uvc_name_transfer_seq
