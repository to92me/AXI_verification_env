`ifndef COUNT_REGISTER_SVH
`define COUNT_REGISTER_SVH



//============================== COUNTER ==================================================
//
//
//===========================================================================================

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
							.individually_accessible 	(0						) );
	endfunction

endclass


`endif