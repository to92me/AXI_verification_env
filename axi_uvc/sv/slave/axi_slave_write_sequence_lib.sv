`ifndef AXI_SLAVE_WRITE_SEAUENCE_LIB_SVH
`define AXI_SLAVE_WRITE_SEAUENCE_LIB_SVH

/**
* Project : AXI UVC
*
* File : axi_slave_write_sequence_base.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Tomislav Tumbas
*
* E-Mail : tomislav.tumbas@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : axi slave write sequence base
*
* Classes :	1. axi_slave_write_sequence_base
*
**/


//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_base_seq
//
//------------------------------------------------------------------------------

class axi_slave_write_sequence_base extends uvm_sequence #(axi_frame);

	// TODO: Add fields here


	// new - constructor
	function new(string name="uvc_name_base_seq");
		super.new(name);
	endfunction

	virtual task pre_body();
	if (starting_phase != null) begin
        starting_phase.raise_objection(this, {"Executing sequence '",
                                              get_full_name(), "'"});
     end
     `uvm_info(get_full_name(), {"Executing sequence '",get_full_name(), "'"}, UVM_MEDIUM)
	endtask

	// Drop the objection in the post_body so the objection is removed when
	// the root sequence is complete.
	virtual task post_body();
		 if (starting_phase != null) begin
        starting_phase.drop_objection(this, {"Completed sequence '",
                                             get_full_name(), "'"});
     end
	endtask

endclass : axi_slave_write_sequence_base

//------------------------------------------------------------------------------
//
// SEQUENCE: uvc_name_transfer_seq
//
//------------------------------------------------------------------------------
class uvc_name_transfer_seq extends axi_slave_write_sequence_base;



	`uvm_object_utils(uvc_name_transfer_seq)


	function new(string name="uvc_name_transfer_seq");
		super.new(name);
	endfunction

	virtual task body();
			`uvm_do(req)
		get_response(rsp);
	endtask

endclass : uvc_name_transfer_seq


`endif
