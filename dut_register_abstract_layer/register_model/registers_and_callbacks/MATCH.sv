`ifndef MATCH_REGISTER_SVH
`define MATCH_REGISTER_SVH


//============================== MATCH SPEC ==================================================
//
//- match registar i match interrupt - u registar bi bila upisana neka vrednost - kad brojac dostigne tu vrednost, generisao bi se interrupt//
//
//===========================================================================================

class MATCH extends uvm_reg;
	rand uvm_reg_field match;

	`uvm_object_utils(MATCH)

	function new (string name = "MATCH");
		super.new(.name(name), .n_bits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction

	function void build();
	match = uvm_reg_field::type_id::create(compare_string);
		match.configure(	.parent						(this					),
							.size						(16						),
							.lsb_pos			    	(MATCH_match_offest	),
							.access						("RW"					),
							.volatile					(0						),
							.reset						(16'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(1						) );
	endfunction

endclass

`endif