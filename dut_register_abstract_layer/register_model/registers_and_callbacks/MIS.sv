`ifndef MIS_REGISTER_SVH
`define MIS_REGISTER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------
//============================== MIS SPEC ==================================================
//- MIS - masked interrupt status 		- bit 0 - overflow
//                                      - bit 1 - underflow
//
//- MIS ima i dodatnu funkcionalnost - upis 1 na odgovarajucu bit lokaciju brise flag i u RIS
// i u MIS registru; upis 0 ne radi nista
//=========================================================================================


class MIS extends uvm_reg;
	rand uvm_reg_field underflow;
	rand uvm_reg_field overflow;
	rand uvm_reg_field match;
	uvm_reg_field reserved;


	`uvm_object_utils(MIS)


	// new - constructor
	function new (string name = "MIS");
		super.new(.name(name), .nbits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build();
		underflow = uvm_reg_field::type_id::create(underflow_string);
		underflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(MIS_underflow_offest	),
							.access						("RW"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );
		begin
			MIS_underflow_cb _MIS_underflow_cb = new("MIS_underflow_cb");
			uvm_reg_field_cb::add(underflow, _MIS_underflow_cb);
		end

		overflow = uvm_reg_field::type_id::create(overflow_string);
		overflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(MIS_overflow_offset	),
							.access						("RW"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );
		begin
			MIS_overflow_cb _MIS_overflow_cb = new("MIS_overflow_cb");
			uvm_reg_field_cb::add(overflow, _MIS_overflow_cb);
		end

		match = uvm_reg_field::type_id::create(match_string);
		match.configure(.parent							(this					),
							.size						(1						),
							.lsb_pos			    	(MIS_match_offset		),
							.access						("RW"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

		begin
			MIS_match_cb _MIS_match_cb = new("MIS_match_cb");
			uvm_reg_field_cb::add(match, _MIS_match_cb);
		end

		reserved = uvm_reg_field::type_id::create(reserved_string);
		reserved.configure(.parent						(this					),
							.size						(13						),
							.lsb_pos			    	(MIS_reserved_offest	),
							.access						("RO"					),
							.volatile					(0						),
							.reset						(0						),
							.has_reset					(0						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );
	endfunction
endclass

// MIS "CALLBACK"

class MIS_overflow_cb extends uvm_reg_cbs;

 `uvm_object_utils(MIS_overflow_cb)

 uvm_reg 		RIS_p, 			IIR_p;
 uvm_reg_field 	RIS_overflow_p, IIR_interrupt_priority_p;


	function new(input string name = "MIS_overflow_cb");
		super.new(name);
		this.init();
	endfunction

	function void init();
	 	 RIS_p = map.get_reg_by_offset(RIS_address_offset);
		 $cast(RIS_overflow_p, RIS_p.get_field_by_name(overflow_string));

		 IIR_p = map.get_reg_by_offset(IIR_address_offset);
		 $cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(interrupt_priority_string));

	endfunction

 	function void post_predict(input uvm_reg_field  fld,
                                      input uvm_reg_data_t previous,
                                      inout uvm_reg_data_t value,
                                      input uvm_predict_e  kind,
                                      input uvm_path_e     path,
                                      input uvm_reg_map    map);



	 if(kind == UVM_WRITE && value == 1)
		 begin
			 if(IIR_interrupt_priority_p.value == 1)
				 begin
					 void'(IIR_interrupt_priority_p.predict(0));
				 end

				 void'(RIS_overflow_p.predict(0));
				 void'(fld.predict(0));
				 value = 0;
		 end
 	endfunction
endclass

class MIS_underflow_cb extends uvm_reg_cbs;

 	`uvm_object_utils(MIS_underflow_cb)

 	uvm_reg 		RIS_p;
	uvm_reg			IIR_p;
	uvm_reg 		MIS_p;

 	uvm_reg_field 	RIS_underflow_p;
	uvm_reg_field 	MIS_overflow_p;
	uvm_reg_field 	IIR_interrupt_priority_p;


	function new(input string name = "MIS_underflow_cb");
	 	super.new(name);
		this.init();
	endfunction


	function init();

		RIS_p = map.get_reg_by_offset(RIS_address_offset);
		$cast(RIS_underflow_p, RIS_p.get_field_by_name(underflow_string));

		IIR_p = map.get_reg_by_offset(IIR_address_offset);
		$cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(interrupt_priority_string));

		MIS_p = map.get_reg_by_offset(MIS_address_offset);
		$cast(MIS_overflow_p,MIS_p.get_field_by_name(overflow_string));


	endfunction

	function void post_predict(input uvm_reg_field  fld,
                                      input uvm_reg_data_t previous,
                                      inout uvm_reg_data_t value,
                                      input uvm_predict_e  kind,
                                      input uvm_path_e     path,
                                      input uvm_reg_map    map);





		if(kind == UVM_PREDICT_WRITE && value == 1)
			begin
				if(RIS_underflow_p.value == 1)
					begin
						void'(RIS_underflow_p.predict(0));
						void'(fld.predict(0));

						if(IIR_interrupt_priority_p.value < 3)
							begin
								if(MIS_overflow_p.value == 1)
									begin
										void'(IIR_interrupt_priority_p.predict(1));
									end
								else
									begin
										void'(IIR_interrupt_priority_p.predict(0));
									end
							end

					end
			end
			value = 0;
	endfunction
endclass


class MIS_match_cb extends uvm_reg_cbs;

 	`uvm_object_utils(MIS_match_cb)


 	uvm_reg 		RIS_p;
	uvm_reg			IIR_p;
	uvm_reg 		MIS_p;

 	uvm_reg_field 	RIS_match_p;

	uvm_reg_field 	MIS_match_p;
	uvm_reg_field 	MIS_overflow_p;
	uvm_reg_field 	MIS_underflow_p;

	uvm_reg_field 	IIR_interrupt_priority_p;

	function new(input string name = "MIS_match_cb");
		super.new(name);
		this.init();
	endfunction

	function void init();

		RIS_p = map.get_reg_by_offset(RIS_address_offset);
		$cast(RIS_match_p, RIS_p.get_field_by_name(underflow_string));

		MIS_p = map.get_reg_by_offset(MIS_address_offset);
		$cast(MIS_match_p, MIS_p.get_field_by_name(match_string));
		$cast(MIS_overflow_p, MIS_p.get_field_by_name(overflow_string));
		$cast(MIS_underflow_p, MIS_p.get_field_by_name(underflow_string));

		IIR_p = map.get_reg_by_offset(IIR_address_offset);
		$cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(underflow_string));

	endfunction

	function void post_predict(input uvm_reg_field  fld,
                                      input uvm_reg_data_t previous,
                                      inout uvm_reg_data_t value,
                                      input uvm_predict_e  kind,
                                      input uvm_path_e     path,
                                      input uvm_reg_map    map);




		if(kind == UVM_PREDICT_WRITE  && value == 1);
		begin
			void'(RIS_match_p.predict(0));
			void'(MIS_match_p.predict(0));
			if(MIS_underflow_p.value == 1)
				begin
					void'(IIR_interrupt_priority_p.predict(0));
				end
			else if(MIS_overflow_p.value == 1)
				begin
					void'(IIR_interrupt_priority_p.predict(1));
				end
			else
				begin
					void'(IIR_interrupt_priority_p.predict(0));
				end
				value = 0;
		end
	endfunction
endclass


`endif