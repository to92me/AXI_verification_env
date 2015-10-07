// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_read_zero_delay.sv
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
* Description : contains sequence for the register model
*
* Sequence : match_seq
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// SEQUENCE: match_seq
//
//------------------------------------------------------------------------------
// -----------------------------------------------------------------------------
/**
*	Description : checks:
*					- writing and reading MATCH register
*					- counter generates interrupt when counter = MATCH
**/
// -----------------------------------------------------------------------------

class match_seq extends register_model_env_pkg::dut_register_model_base_sequence;

	dut_register_block		register_model;
	uvm_status_e			status;

	`uvm_object_utils(match_seq)

	// new - constructor
	function new(string name="match_seq");
		super.new(name);
	endfunction

	virtual task body();

		$display("");
		$display("=================================================================================================================================================================");
		$display("=\t\t\t\t\t\t\t\t\tMATCH_SEQ\t\t\t\t\t\t\t\t\t\t=");
		$display("=================================================================================================================================================================");
		$display("");

		#1000
		// start counter
		register_model.CFG_reg.write(status, 1);
		// enable IM
		register_model.IM_reg.write(status, 15);

		#1000
		// read from MATCH
		register_model.MATCH_reg.mirror(status, UVM_CHECK);
		// read RIS and MIS
		register_model.RIS_reg.mirror(status, UVM_CHECK);
		register_model.MIS_reg.mirror(status, UVM_CHECK);

		// read IIR to clear MATCH interrupt
		register_model.IIR_reg.mirror(status, UVM_CHECK);

		#1000
		// read RIS and MIS - match interrupt should be clear
		register_model.RIS_reg.mirror(status, UVM_CHECK);
		register_model.MIS_reg.mirror(status, UVM_CHECK);

		// set MATCH
		register_model.MATCH_reg.write(status, 4500);

		#1000
		// read MATCH
		register_model.MATCH_reg.mirror(status, UVM_CHECK);

		// read RIS and MIS - check if interrupt is generated
		register_model.RIS_reg.mirror(status, UVM_CHECK);
		register_model.MIS_reg.mirror(status, UVM_CHECK);

		$display("");
		$display("=================================================================================================================================================================");
		$display("=\t\t\t\t\t\t\t\t\tEND MATCH_SEQ\t\t\t\t\t\t\t\t\t\t=");
		$display("=================================================================================================================================================================");
		$display("");

	endtask

endclass : match_seq