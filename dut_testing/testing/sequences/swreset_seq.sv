// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : swreset_seq.sv
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
* Sequence : swreset_seq
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// SEQUENCE: swreset_seq
//
//------------------------------------------------------------------------------
// -----------------------------------------------------------------------------
/**
*	Description : checks:
*					- reading from SWRESET always returns 0
*					- writing 0x5A resets all registers
*					- writing anything else does nothing
**/
// -----------------------------------------------------------------------------

class swreset_seq extends dut_register_model_base_sequence;

	`uvm_object_utils(swreset_seq)
	int i;

	// new - constructor
	function new(string name="swreset_seq");
		super.new(name);
	endfunction

	virtual task body();

		log.configure("SWRESET_SEQ", FALSE, FALSE);

		log.restoreContex("swreset_seq", register_model);

		#1000
		// start counter
		log.reg_do(register_model.CFG_reg, WRITE, 3);
		// enable IM
		log.reg_do(register_model.IM_reg, WRITE, 15);
		// set MATCH and LOAD
		log.reg_do(register_model.MATCH_reg, WRITE, 'hff5a);
		log.reg_do(register_model.LOAD_reg, WRITE, 'hff5a);

		#1000
		// read from SWRESET
		log.reg_do(register_model.SWRESET_reg, MIRROR);

		#1000
		// read RIS, MIS, IM, MATCH and LOAD
		log.reg_do(register_model.RIS_reg, MIRROR);
		log.reg_do(register_model.MIS_reg, MIRROR);
		log.reg_do(register_model.IM_reg, MIRROR);
		log.reg_do(register_model.MATCH_reg, MIRROR);
		log.reg_do(register_model.LOAD_reg, MIRROR);

		// write incorrect code to SWRESET
		log.reg_do(register_model.SWRESET_reg, WRITE, 3, TRUE);

		#1000
		// check RIS, MIS, IM, MATCH and LOAD
		log.reg_do(register_model.RIS_reg, MIRROR);
		log.reg_do(register_model.MIS_reg, MIRROR);
		log.reg_do(register_model.IM_reg, MIRROR);
		log.reg_do(register_model.MATCH_reg, MIRROR);
		log.reg_do(register_model.LOAD_reg, MIRROR);

		#1000
		// read from SWRESET
		log.reg_do(register_model.SWRESET_reg, MIRROR);

		#1000
		// write correct code to SWRESET
		log.reg_do(register_model.SWRESET_reg, MIRROR, 'h005A);

		#1000
		// check RIS, MIS, IM, MATCH and LOAD - they should reset
		log.reg_do(register_model.RIS_reg, MIRROR);
		log.reg_do(register_model.MIS_reg, MIRROR);
		log.reg_do(register_model.IM_reg, MIRROR);
		log.reg_do(register_model.MATCH_reg, MIRROR);
		log.reg_do(register_model.LOAD_reg, MIRROR);

		#1000
		// read from SWRESET
		log.reg_do(register_model.SWRESET_reg, MIRROR);

		log.printStatus();

		log.storeResults("swreset_seq");
		log.storeContex("swreset_seq", register_model);

	endtask

endclass : swreset_seq