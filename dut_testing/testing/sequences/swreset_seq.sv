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

class swreset_seq extends register_model_env_pkg::dut_register_model_base_sequence;

	dut_register_block		register_model;
	uvm_status_e			status;

	`uvm_object_utils(swreset_seq)

	// new - constructor
	function new(string name="swreset_seq");
		super.new(name);
	endfunction

	virtual task body();

		$display("");
		$display("==============================================================================================================================================================");
		$display("=                                                            	SWRESET_SEQ                                                                                    =");
		$display("==============================================================================================================================================================");
		$display("");

		#100
		// start counter
		register_model.CFG_reg.write(status, 3);
		// enable IM
		register_model.IM_reg.write(status, 15);
		// set MATCH and LOAD
		register_model.MATCH_reg.write(status, 'hff5a);
		register_model.LOAD_reg.write(status, 'hff5a);

		#100
		// read from SWRESET
		register_model.SWRESET_reg.mirror(status, UVM_CHECK);

		#1000
		// read RIS, MIS, IM, MATCH and LOAD
		register_model.RIS_reg.mirror(status, UVM_CHECK);
		register_model.MIS_reg.mirror(status, UVM_CHECK);
		register_model.IM_reg.mirror(status, UVM_CHECK);
		register_model.MATCH_reg.mirror(status, UVM_CHECK);
		register_model.LOAD_reg.mirror(status, UVM_CHECK);

		// write incorrect code to SWRESET
		register_model.SWRESET_reg.write(status, 3);

		#100
		// check RIS, MIS, IM, MATCH and LOAD
		register_model.RIS_reg.mirror(status, UVM_CHECK);
		register_model.MIS_reg.mirror(status, UVM_CHECK);
		register_model.IM_reg.mirror(status, UVM_CHECK);
		register_model.MATCH_reg.mirror(status, UVM_CHECK);
		register_model.LOAD_reg.mirror(status, UVM_CHECK);

		#100
		// read from SWRESET
		register_model.SWRESET_reg.mirror(status, UVM_CHECK);

		#100
		// write correct code to SWRESET
		register_model.SWRESET_reg.write(status, 3);

		#100
		// check RIS, MIS, IM, MATCH and LOAD - they should reset
		register_model.RIS_reg.mirror(status, UVM_CHECK);
		register_model.MIS_reg.mirror(status, UVM_CHECK);
		register_model.IM_reg.mirror(status, UVM_CHECK);
		register_model.MATCH_reg.mirror(status, UVM_CHECK);
		register_model.LOAD_reg.mirror(status, UVM_CHECK);

		#100
		// read from SWRESET
		register_model.SWRESET_reg.mirror(status, UVM_CHECK);

		$display("");
		$display("==============================================================================================================================================================");
		$display("=                                                          END SWRESET_SEQ                                                                                   =");
		$display("==============================================================================================================================================================");
		$display("");

	endtask

endclass : swreset_seq