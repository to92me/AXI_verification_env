// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : load_seq.sv
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
* Sequence : load_seq
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// SEQUENCE: load_seq
//
//------------------------------------------------------------------------------
// -----------------------------------------------------------------------------
/**
*	Description : check LOAD reg
**/
// -----------------------------------------------------------------------------

class load_seq extends dut_register_model_base_sequence;

	`uvm_object_utils(load_seq)

	// new - constructor
	function new(string name="load_seq");
		super.new(name);
	endfunction

	virtual task body();
	
		log.configure("load_seq", TRUE, TRUE);

		#100
		// start counter
		log.reg_do(register_model.CFG_reg, WRITE, 1);
		// set LOAD value
		log.reg_do(register_model.LOAD_reg, WRITE, 100);

		#1000
		// read LOAD
		log.reg_do(register_model.LOAD_reg, WRITE, 0);

		#1000
		// set LOAD value
		log.reg_do(register_model.LOAD_reg, WRITE, 2);

		#1000
		// read LOAD
		log.reg_do(register_model.LOAD_reg, WRITE, 0);

		log.printStatus();

	endtask

endclass : load_seq