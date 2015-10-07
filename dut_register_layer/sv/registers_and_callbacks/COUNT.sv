`ifndef COUNT_REGISTER_SVH
`define COUNT_REGISTER_SVH

/**
* Project : DUT register model
*
* File : COUNTER.sv
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
* Description : COUNTER register model
*
* Classes :	1. COUNTER
*
**/


//-------------------------------------------------------------------------------------
//
// CLASS: COUNTER
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			COUNTER register, represents image of dut COUNTER register written in uvm
//
//
// SPECIFICATION:
//			COUNTER, standard counter.
//
//
//-------------------------------------------------------------------------------------

class COUNT extends uvm_reg;
	uvm_reg_field counter;

	`uvm_object_utils(COUNT)

	function new (string name = "COUNT");
		super.new(.name(name), .n_bits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction

	function void build();
	counter = uvm_reg_field::type_id::create(counter_string);
		counter.configure(	.parent						(this					),
							.size						(16						),
							.lsb_pos			    	(COUNT_counter_offest	),
							.access						("RO"					),
							.volatile					(1						),
							.reset						(16'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(1						) );
		counter.set_compare(UVM_CHECK);
	endfunction

endclass


`endif