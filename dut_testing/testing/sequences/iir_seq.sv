// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : iir_seq.sv
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
* Sequence : iir_seq
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// SEQUENCE: iir_seq
//
//------------------------------------------------------------------------------
// -----------------------------------------------------------------------------
/**
*	Description : checks:
*					- IIR upates according to MIS
*					- reading it clears interrupt
**/
// -----------------------------------------------------------------------------

class iir_seq extends dut_register_model_base_sequence;

	`uvm_object_utils(iir_seq)

	// new - constructor
	function new(string name="iir_seq");
		super.new(name);
	endfunction

	virtual task body();

		log.configure("iir_seq", TRUE, TRUE);

		#1000
		// start counter
		log.reg_do(register_model.CFG_reg, WRITE, 3);
		// enable IM
		log.reg_do(register_model.IM_reg, WRITE, 15);

		#1000
		// read RIS, MIS, IM
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);
		log.reg_do(register_model.IM_reg, MIRROR, 0);

		// read IIR
		log.reg_do(register_model.IIR_reg, MIRROR, 0);

		#1000
		// check RIS, MIS, IM
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);
		log.reg_do(register_model.IM_reg, MIRROR, 0);

		#1000
		// read IIR
		log.reg_do(register_model.IIR_reg, MIRROR, 0);

		#1000
		// check RIS, MIS, IM
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);
		log.reg_do(register_model.IM_reg, MIRROR, 0);

		#1000
		// change direction of counter - goal overflow interrupt
		log.reg_do(register_model.CFG_reg, WRITE, 1);

		#10000
		// read RIS, MIS, IM
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);
		log.reg_do(register_model.IM_reg, MIRROR, 0);

		// read IIR
		log.reg_do(register_model.IIR_reg, MIRROR, 0);

		#1000
		// check RIS, MIS, IM
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);
		log.reg_do(register_model.IM_reg, MIRROR, 0);

		#1000
		// read IIR
		log.reg_do(register_model.IIR_reg, MIRROR, 0);

		#1000
		// check RIS, MIS, IM
		log.reg_do(register_model.RIS_reg, MIRROR, 0);
		log.reg_do(register_model.MIS_reg, MIRROR, 0);
		log.reg_do(register_model.IM_reg, MIRROR, 0);

		log.printStatus();

	endtask

endclass : iir_seq