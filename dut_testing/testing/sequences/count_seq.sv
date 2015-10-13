// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : count_seq.sv
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
* Sequence : count_seq
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// SEQUENCE: count_seq
//
//------------------------------------------------------------------------------
// -----------------------------------------------------------------------------
/**
*	Description : check COUNT reg
**/
// -----------------------------------------------------------------------------

class count_seq extends dut_register_model_base_sequence;

	`uvm_object_utils(count_seq)

	// new - constructor
	function new(string name="count_seq");
		super.new(name);
	endfunction

	virtual task body();
	
		log.configure("COUNT_SEQ", TRUE, FALSE);

		log.restoreContex("active_ctx", register_model);

		#100
		// start counter
		log.reg_do(register_model.CFG_reg, WRITE, 1);

		#1000
		// stop counter
		log.reg_do(register_model.CFG_reg, WRITE, 0);

		#1000
		// read value
		log.reg_do(register_model.COUNT_reg, MIRROR, 0);

		log.printStatus();

		log.storeResults("count_seq");
		log.storeContex("active_ctx", register_model);

	endtask

endclass : count_seq