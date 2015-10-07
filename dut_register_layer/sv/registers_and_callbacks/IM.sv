`ifndef IM_REGISTER_SVH_
`define IM_REGISTER_SVH_

/**
* Project : DUT register model
*
* File : IM.sv
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
* Description : IM register model
*
*
**/


//-------------------------------------------------------------------------------------
//
// CLASS: IM
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			IM register, represents image of dut IM register written in uvm
//
//
// SPECIFICATION:
//	 	IM - interrupt enable - bit 0
//				 - overflow
//               - bit 1 - underflow
//               - ta dva polja su read-write, ostala su read-only
// 				ne menja ga hardwer
//-------------------------------------------------------------------------------------



class IM extends uvm_reg;
	rand uvm_reg_field underflow;
	rand uvm_reg_field overflow;
	rand uvm_reg_field match;
	uvm_reg_field reserved;


	`uvm_object_utils(IM)



	// new - constructor
	function new (string name = "IM");
		super.new(.name(name), .n_bits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build();
		underflow = uvm_reg_field::type_id::create(underflow_string);
		underflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(IM_underflow_offest	),
							.access						("RW"					),
							.volatile					(0						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(1						) );
		begin
			IM_underflow_cb _IM_underflow_cb = new("IM_underflow_cb");
			uvm_reg_field_cb::add(underflow, _IM_underflow_cb);
		end
		underflow.set_compare(UVM_CHECK);

		overflow = uvm_reg_field::type_id::create(overflow_string);
		overflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(IM_overflow_offset	),
							.access						("RW"					),
							.volatile					(0						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(1						) );
		begin
			IM_overflow_cb _IM_overflow_cb = new("IM_overflow_cb");
			uvm_reg_field_cb::add(overflow, _IM_overflow_cb);
		end
		overflow.set_compare(UVM_CHECK);

		match = uvm_reg_field::type_id::create(match_string);
		match.configure(.parent							(this					),
							.size						(1						),
							.lsb_pos			    	(IM_match_offset		),
							.access						("RW"					),
							.volatile					(0						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(1						) );
		begin
			IM_match_cb _IM_match_cb = new("IM_match_cb");
			uvm_reg_field_cb::add(match, _IM_match_cb);
		end
		match.set_compare(UVM_CHECK);

		reserved = uvm_reg_field::type_id::create(reserved_string);
		reserved.configure(.parent						(this					),
							.size						(13						),
							.lsb_pos			    	(IM_reserved_offest	),
							.access						("RO"					),
							.volatile					(0						),
							.reset						(0						),
							.has_reset					(0						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );
	endfunction
endclass


//-------------------------------------------------------------------------------------
//
// CLASS: IM_overflow_cb
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			IM_overflow_cb is callback that is called after calling predict on IM register that changes
//			corresponding values in register model
//
//
// SPECIFICATION:
//			if in IM_overflow is written 1 then if RIS_overflow is 1 this callback will
//			change MIS_overflow to 1 and IIR to corresponding value
//
//-------------------------------------------------------------------------------------


class IM_overflow_cb extends uvm_reg_cbs;
	uvm_reg 		RIS_p;
	uvm_reg 		MIS_p;
	uvm_reg			IIR_p;

	uvm_reg_field 	RIS_overflow_p;
	uvm_reg_field 	MIS_overflow_p;
	uvm_reg_field 	IIR_interrupt_priority;


	function new(string name = "IM_overflow_cb");
		super.new(name);
//		this.init();
	endfunction

	function void init(uvm_reg_map map);

		RIS_p = map.get_reg_by_offset(RIS_address_offset);
		$cast(RIS_overflow_p, RIS_p.get_field_by_name(overflow_string));

		MIS_p = map.get_reg_by_offset(MIS_address_offset);
		$cast(MIS_overflow_p, MIS_p.get_field_by_name(overflow_string));

		IIR_p = map.get_reg_by_offset(IIR_address_offset);
		$cast(IIR_interrupt_priority, IIR_p.get_field_by_name(interrupt_priority_string));

	endfunction

	function void post_predict( input uvm_reg_field  fld,
                               	input uvm_reg_data_t previous,
                                inout uvm_reg_data_t value,
                                input uvm_predict_e  kind,
                                input uvm_path_e     path,
                                input uvm_reg_map    map);
	this.init(map);


	if(kind == UVM_PREDICT_WRITE && value == 1)
		begin
			if(RIS_overflow_p.value == 1)
				begin
					void'(MIS_overflow_p.predict(1));

							// if interrupt priority is less than 1 then predict 1
					if(IIR_interrupt_priority.value < 1)
						begin
							void'(IIR_interrupt_priority.predict(1));
						end
				end
		end

	endfunction

endclass

//-------------------------------------------------------------------------------------
//
// CLASS: IM_underflow_cb
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			IM_underflow_cb is callback that is called after calling predict on IM register that changes
//			corresponding values in register model
//
//
// SPECIFICATION:
//			if in IM_underflow is written 1 then if RIS_underflow is 1 this callback will
//			change MIS_overflow to 1 and IIR to corresponding value
//
//-------------------------------------------------------------------------------------

class IM_underflow_cb extends uvm_reg_cbs;
	uvm_reg 		RIS_p;
	uvm_reg 		MIS_p;
	uvm_reg			IIR_p;

	uvm_reg_field  RIS_underflow_p;
	uvm_reg_field  MIS_underflow_p;
	uvm_reg_field  IIR_interrupt_priority_p;

	function new(string name = "IM_underflow_cb");
		super.new(name);
//		this.init();
	endfunction

	function void init(uvm_reg_map map);

		RIS_p = map.get_reg_by_offset(RIS_address_offset);
		$cast(RIS_underflow_p, RIS_p.get_field_by_name(underflow_string));

		MIS_p = map.get_reg_by_offset(MIS_address_offset);
		$cast(MIS_underflow_p, MIS_p.get_field_by_name(underflow_string));

		IIR_p = map.get_reg_by_offset(IIR_address_offset);
		$cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(interrupt_priority_string));


	endfunction

	function void post_predict( input uvm_reg_field  fld,
                               	input uvm_reg_data_t previous,
                                inout uvm_reg_data_t value,
                                input uvm_predict_e  kind,
                                input uvm_path_e     path,
                                input uvm_reg_map    map);

	this.init(map);

		if(kind == UVM_PREDICT_WRITE && value == 1)
			begin
				if(RIS_underflow_p.value == 1)
					begin
						void'(MIS_underflow_p.predict(1));
						if(IIR_interrupt_priority_p.value < 2)
							begin
								void'(IIR_interrupt_priority_p.predict(1));
							end
					end
			end
	endfunction


endclass

//-------------------------------------------------------------------------------------
//
// CLASS: IM_match_cb
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			IM_match_cb is callback that is called after calling predict on IM register that changes
//			corresponding values in register model
//
//
// SPECIFICATION:
//			if in IM_match is written 1 then if RIS_match is 1 this callback will
//			change MIS_match to 1 and IIR to corresponding value
//
//-------------------------------------------------------------------------------------

class IM_match_cb extends uvm_reg_cbs;
	uvm_reg 		RIS_p;
	uvm_reg 		MIS_p;
	uvm_reg			IIR_p;

	uvm_reg_field  RIS_match_p;
	uvm_reg_field  MIS_match_p;
	uvm_reg_field  IIR_interrupt_priority_p;


	function new(string name = "IM_match_cb");
		super.new(name);
//		this.init();
	endfunction

	function void init(input uvm_reg_map map);

		RIS_p = map.get_reg_by_offset(RIS_address_offset);
		$cast(RIS_match_p, RIS_p.get_field_by_name(match_string));

		MIS_p = map.get_reg_by_offset(MIS_address_offset);
		$cast(MIS_match_p, MIS_p.get_field_by_name(match_string));

		IIR_p = map.get_reg_by_offset(IIR_address_offset);
		$cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(interrupt_priority_string));


	endfunction



	function void post_predict( input uvm_reg_field  fld,
                               	input uvm_reg_data_t previous,
                                inout uvm_reg_data_t value,
                                input uvm_predict_e  kind,
                                input uvm_path_e     path,
                                input uvm_reg_map    map);

	this.init(map);

	if(kind == UVM_PREDICT_WRITE && value == 1)
		begin
			if(RIS_match_p.value == 1)
				begin
					void'(MIS_match_p.predict(1));
					if(IIR_interrupt_priority_p.value != 3)
						begin
							void'(IIR_interrupt_priority_p.predict(3));
						end
				end
		end
	endfunction


endclass



`endif