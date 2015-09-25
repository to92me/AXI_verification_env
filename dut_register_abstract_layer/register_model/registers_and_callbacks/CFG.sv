`ifndef CFG_REGISTER_SVH
`define CFG_REGISTER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------



//============================== CFG SPEC ==================================================
//- CFG registar - bit 0 - counter enable - enable-uje brojanje
//                        - bit 1 - up/down - vrednost 0 je up; vrednost 1 je down
//                        - polja su read-write, ostala su read-only
//===========================================================================================


class CFG extends uvm_reg;
	rand uvm_reg_field counter_enable;
	rand uvm_reg_field direction; // up = 0, down = 1
	uvm_reg_field reserved;

	`uvm_object_utils(CFG)


	// new - constructor
	function new (string name = "CFG");
		super.new(.name(name), .n_bits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build();
		counter_enable = uvm_reg_field::type_id::create(counter_enable_string);
		counter_enable.configure(.parent				(this						),
							.size						(1							),
							.lsb_pos			    	(CFG_counter_enable_offset	),
							.access						("RW"						),
							.volatile					(0							),
							.reset						(1'b0						),
							.has_reset					(1							),
							.is_rand					(0							),
							.individually_accessible 	(0							) );


		direction = uvm_reg_field::type_id::create(counter_direction_string);
		direction.configure(.parent						(this						),
							.size						(1							),
							.lsb_pos			    	(CFG_counter_direction_offset),
							.access						("RW"						),
							.volatile					(0							),
							.reset						(1'b0						),
							.has_reset					(1							),
							.is_rand					(0							),
							.individually_accessible 	(0							) );

		reserved = uvm_reg_field::type_id::create(reserved_string);
		reserved.configure( .parent						(this						),
							.size						(14							),
							.lsb_pos			    	(CFG_reserved_offset		),
							.access						("RO"						),
							.volatile					(0							),
							.reset						(0							),
							.has_reset					(0							),
							.is_rand					(0							),
							.individually_accessible 	(0							) );
	endfunction
endclass



`endif