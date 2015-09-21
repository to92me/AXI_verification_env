`ifndef RIS_REGISTER_SVH
`define RIS_REGISTER_SVH



//============================== RIS SPEC ================================================
//- RIS - bit 0 - overflow
//          - bit 1 - underflow
//          - registar je read-only, polja setuje hardver
//=========================================================================================


class RIS extends uvm_reg;
	uvm_reg_field underflow;
	uvm_reg_field overflow;
	uvm_reg_field match;
	uvm_reg_field reserved;


	`uvm_object_utils(RIS)



	// new - constructor
	function new (string name = "RIS");
		super.new(.name(name), .nbits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build();
		underflow = uvm_reg_field::type_id::create(underflow_string);
		underflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(RIS_underflow_offset	),
							.access						("RO"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

		overflow = uvm_reg_field::type_id::create(overflow_string);
		overflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(RIS_overflow_offset	),
							.access						("RO"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

		match = uvm_reg_field::type_id::create(match_string);
		match.configure(.parent							(this					),
							.size						(1						),
							.lsb_pos			    	(RIS_match_offset		),
							.access						("RO"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

		reserved = uvm_reg_field::type_id::create(reserved_string);
		reserved.configure( .parent						(this					),
							.size						(13						),
							.lsb_pos			    	(RIS_reserved_offest	),
							.access						("RO"					),
							.volatile					(0						),
							.reset						(0						),
							.has_reset					(0						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );
	endfunction
endclass




`endif