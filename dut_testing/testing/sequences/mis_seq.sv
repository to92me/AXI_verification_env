// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : mis_seq.sv
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
* Sequence : mis_seq
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// SEQUENCE: mis_seq
//
//------------------------------------------------------------------------------
// -----------------------------------------------------------------------------
/**
*	Description : checks:
*					- MIS upates according to RIS and IM
*					- writing 1 clears interrupt
**/
// -----------------------------------------------------------------------------

class mis_seq extends dut_register_model_base_sequence;

	`uvm_object_utils(mis_seq)

	// new - constructor
	function new(string name="mis_seq");
		super.new(name);
	endfunction

	virtual task body();

		log.configure("mis_seq", TRUE, FALSE);

		log.restoreContex("active_ctx", register_model);

		#1000
		// start counter
		log.reg_do(register_model.CFG_reg, WRITE, 3);

		#1000
		// read RIS, MIS, IM
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);
		log.reg_do(register_model.IM_reg, MIRROR, 0);

		// enable IM
		log.reg_do(register_model.IM_reg, WRITE, 15);

		#1000
		// check RIS, MIS, IM
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);
		log.reg_do(register_model.IM_reg, MIRROR, 0);

		#1000
		// write 1 to MIS match bit
		log.reg_do(register_model.MIS_reg, WRITE, 4);

		#1000
		// check RIS, MIS, IM
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);
		log.reg_do(register_model.IM_reg, MIRROR, 0);

		#1000
		// write 1 to MIS underflow bit
		log.reg_do(register_model.MIS_reg, WRITE, 2);

		#10000
		// check RIS, MIS, IM
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);
		log.reg_do(register_model.IM_reg, MIRROR, 0);

		// clear IM
		log.reg_do(register_model.IM_reg, WRITE, 0);

		#1000
		// check RIS, MIS, IM
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);
		log.reg_do(register_model.IM_reg, MIRROR, 0);

		#1000
		// write 0 to MIS - nothing should changeq
		log.reg_do(register_model.MIS_reg, WRITE, 0);

		#1000
		// check RIS, MIS, IM
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);
		log.reg_do(register_model.IM_reg, MIRROR, 0);

		log.printStatus();

		log.storeResults("mis_seq");
		log.storeContex("active_ctx", register_model);

	endtask

endclass : mis_seq