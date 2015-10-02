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

class count_seq extends register_model_env_pkg::dut_register_model_base_sequence;

	dut_register_block		register_model;
	uvm_status_e			status;

	`uvm_object_utils(count_seq)

	// new - constructor
	function new(string name="count_seq");
		super.new(name);
	endfunction

	virtual task body();

		$display("");
		$display("==============================================================================================================================================================");
		$display("=                                                            	COUNT_SEQ                                                                                    =");
		$display("==============================================================================================================================================================");
		$display("");

		// start counter
		register_model.CFG_reg.write(status, 1);

		#1000
		// stop counter
		register_model.CFG_reg.write(status, 0);

		#1000
		// read value
		register_model.COUNT_reg.mirror(status, UVM_CHECK);

		$display("");
		$display("==============================================================================================================================================================");
		$display("=                                                          END COUNT_SEQ                                                                                     =");
		$display("==============================================================================================================================================================");
		$display("");

	endtask

endclass : count_seq