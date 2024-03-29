`ifndef LOAD_REGISTER_SVH
`define LOAD_REGISTER_SVH


/**
* Project : DUT register model
*
* File : LOAD.sv
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
* Description : LOAD register model
*
*
**/


//-------------------------------------------------------------------------------------
//
// CLASS: LOAD
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			LOAD register, represents image of dut LOAD register written in uvm
//
//
// SPECIFICATION:
//	 	//- LOAD registar - 16bitna vrednost sa kojom se poredi brojac
//                           - registar je read-write
//-------------------------------------------------------------------------------------


class LOAD extends uvm_reg;
 	rand uvm_reg_field compare;

	`uvm_object_utils(LOAD)

	// new - constructor
	function new (string name = "LOAD");
		super.new(.name(name), .n_bits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new


	function void build();
		compare = uvm_reg_field::type_id::create(compare_string);
		compare.configure(.parent						(this					),
							.size						(16						),
							.lsb_pos			    	(LOAD_compare_offest	),
							.access						("RW"					),
							.volatile					(0						),
							.reset						(16'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(1						) );
	endfunction
endclass



`endif