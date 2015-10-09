// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : match_seq.sv
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

class match_seq extends dut_register_model_base_sequence;

	`uvm_object_utils(match_seq)

	// new - constructor
	function new(string name="match_seq");
		super.new(name);
	endfunction

	virtual task body();

		log.configure("MATCH_SEQ", TRUE, TRUE);

		#100
		// start counter
		log.reg_do(register_model.CFG_reg, WRITE, 1);
		// enable IM
		log.reg_do(register_model.IM_reg, WRITE, 15);

		#1000
		// read from MATCH
		log.reg_do(register_model.MATCH_reg, MIRROR, 0);
		// read RIS and MIS
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);

		// read IIR to clear MATCH interrupt
		log.reg_do(register_model.IIR_reg, MIRROR, 0);

		#1000
		// read RIS and MIS - match interrupt should be clear
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);

		// set MATCH
		log.reg_do(register_model.MATCH_reg, WRITE, 4500);

		#1000
		// read MATCH
		log.reg_do(register_model.MATCH_reg, MIRROR, 0);

		// read RIS and MIS - check if interrupt is generated
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);

		log.printStatus();

	endtask

endclass : match_seq