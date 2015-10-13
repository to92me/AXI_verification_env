`ifndef IIR_REGISTER_SVH
`define IIR_REGISTER_SCH

/**
* Project : DUT register model
*
* File : IIR.sv
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
* Description : IIR register model
*
*
**/


//-------------------------------------------------------------------------------------
//
// CLASS: IIR
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			IIR register, represents image of dut IIR register written in uvm
//
//
// SPECIFICATION:
//			 interrupt index registar - registar prioriteta - npr u slucaju da je bit 0 u MIS aktivan, ovaj registar bi imao vrednost 1
//            - u slucaju da je bit 1 u MIS aktivan, ovaj registar bi imao vrednost 2
//            - u slucaju da je bit 0 i 1 u MIS aktivan, ovaj registar bi opet imao vrednost 2, znaci bit 1 bi se
//         		  proglasio za interrupt viseg prioriteta
//-------------------------------------------------------------------------------------



class IIR extends uvm_reg;
	rand uvm_reg_field interrupt_priority;
	uvm_reg_field reserved;

	`uvm_object_utils(IIR)

	function new (string name = "IIR");
		super.new(.name(name), .n_bits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction

	function void build();
	interrupt_priority = uvm_reg_field::type_id::create(interrupt_priority_string);
	interrupt_priority.configure(.parent				(this					),
							.size						(2						),
							.lsb_pos			    	(IIR_interrupt_offset	),
							.access						("RO"					),
							.volatile					(1						),
							.reset						(2'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(1						) );
		begin
			IIR_interrupt_priority_cb _IIR_interrupt_priority_cb = new("IIR_interrupt_priority_cb");
			uvm_reg_field_cb::add(interrupt_priority, _IIR_interrupt_priority_cb);
		end
	interrupt_priority.set_compare(UVM_CHECK);

	reserved = uvm_reg_field::type_id::create(reserved_string);
	reserved.configure(		.parent						(this					),
							.size						(14						),
							.lsb_pos			    	(IIR_reserved			),
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
// CLASS: IIR_interrupt_priority_cb
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			IIR_interrupt_priority_cb is callback that is called after calling predict on IIR register that changes
//			corresponding values in register model
//
//
// SPECIFICATION:
//			ako se cita IIR treba da se spusti interrupt najveceg prioriteta
//
//
//-------------------------------------------------------------------------------------


class IIR_interrupt_priority_cb extends uvm_reg_cbs;
	uvm_reg RIS_p;
	uvm_reg MIS_p;
	uvm_reg IM_p;

	uvm_reg_field RIS_overflow_p;
	uvm_reg_field RIS_underflow_p;
	uvm_reg_field RIS_match_p;

	uvm_reg_field MIS_overflow_p;
	uvm_reg_field MIS_underflow_p;
	uvm_reg_field MIS_match_p;


	function new(input string name = "IIR_interrupt_priority_cb");
		super.new(name);
//		this.init();
	endfunction

	function void init(input uvm_reg_map map);
		RIS_p = map.get_reg_by_offset(RIS_address_offset);
		$cast(RIS_overflow_p , RIS_p.get_field_by_name(overflow_string));
		$cast(RIS_underflow_p , RIS_p.get_field_by_name(underflow_string));
		$cast(RIS_match_p , RIS_p.get_field_by_name(match_string));

		MIS_p = map.get_reg_by_offset(MIS_address_offset);
		$cast(MIS_overflow_p , MIS_p.get_field_by_name(overflow_string));
		$cast(MIS_underflow_p , MIS_p.get_field_by_name(underflow_string));
		$cast(MIS_match_p , MIS_p.get_field_by_name(match_string));
	endfunction

	function void post_predict(input uvm_reg_field  fld,
                                      input uvm_reg_data_t previous,
                                      inout uvm_reg_data_t value,
                                      input uvm_predict_e  kind,
                                      input uvm_path_e     path,
                                      input uvm_reg_map    map);

	this.init(map);

	if(kind == UVM_PREDICT_READ)
		begin
			case(value)

// VALUE 3
				3:
				begin
					void'(RIS_match_p.predict(0));
					if(MIS_match_p.value == 1)
						begin
							void'(MIS_match_p.predict(0));
						end

					if(MIS_underflow_p.value == 1)
						begin
							//void'(fld.predict(2));
							value = 2;
						end

					else if(MIS_overflow_p.value == 1)
						begin
						//void'(fld.predict(1));
							value = 1;
						end

					else
						begin
							//void'(fld.predict(0));
							value = 0;
						end
				end

// VALUE 2
				2:
				begin
					void'(RIS_underflow_p.predict(0));
					if(MIS_underflow_p.value == 1)
						begin
							void'(MIS_underflow_p.predict(0));
						end

				 if(MIS_overflow_p.value == 1)
						begin
						//void'(fld.predict(1));
						value = 1;
						end
				 else
					 begin
						// void'(fld.predict(0));
						value = 0;
					 end
				end

//VALUE 1
				1:
				begin
					 void'(RIS_overflow_p.predict(0));
					if(MIS_overflow_p.value == 1)
						begin
							 void'(MIS_overflow_p.predict(0));
						end

					 //void'(fld.predict(0));
						value = 0;
				end

				0:
				begin
					// no operation
				end
			endcase
		end
	endfunction
endclass



`endif