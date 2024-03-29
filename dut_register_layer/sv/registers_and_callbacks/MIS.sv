`ifndef MIS_REGISTER_SVH
`define MIS_REGISTER_SVH


/**
* Project : DUT register model
*
* File : MIS.sv
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
* Description : MIS register model
*
*
**/


//-------------------------------------------------------------------------------------
//
// CLASS: MIS
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			MIS register, represents image of dut MIS register written in uvm
//
//
// SPECIFICATION:
//	  MIS - masked interrupt status 		- bit 0 - overflow
//                                      	- bit 1 - underflow
//
//		- MIS ima i dodatnu funkcionalnost - upis 1 na odgovarajucu bit lokaciju brise flag i u RIS
// 		i u MIS registru; upis 0 ne radi nista
//-------------------------------------------------------------------------------------
// ISSUE :
//		problem sa callback-om - kada se upise 1 na odgovarajucu bit lokaciju treba da se
//		obrise taj prekid u RIS i MIS registrima.
//
//		RIS registar se korektno setuje (tj. clear-uje)
//
//		problem je u MIS-u - pozove se odgovarajuci callback, ali se polja ne setuju korektno
//		probali smo:
//			- value = 0 - ceo MIS dobije vrednost 0 (a ne samo taj bit)
//			- fld.predict(0)
//			- MIS.predict
//			- MIS_match_p.predict(0));
//			- fld.value = 0
//			- ...
//-------------------------------------------------------------------------------------

class MIS extends uvm_reg;
	rand uvm_reg_field underflow;
	rand uvm_reg_field overflow;
	rand uvm_reg_field match;
	uvm_reg_field reserved;


	`uvm_object_utils(MIS)


	// new - constructor
	function new (string name = "MIS");
		super.new(.name(name), .n_bits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build();
		underflow = uvm_reg_field::type_id::create(underflow_string);
		underflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(MIS_underflow_offest	),
							.access						("W1C"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(1						) );
		begin
			MIS_underflow_cb _MIS_underflow_cb = new("MIS_underflow_cb");
			uvm_reg_field_cb::add(underflow, _MIS_underflow_cb);
		end
		underflow.set_compare(UVM_CHECK);

		overflow = uvm_reg_field::type_id::create(overflow_string);
		overflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(MIS_overflow_offset	),
							.access						("W1C"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(1						) );
		begin
			MIS_overflow_cb _MIS_overflow_cb = new("MIS_overflow_cb");
			uvm_reg_field_cb::add(overflow, _MIS_overflow_cb);
		end
		overflow.set_compare(UVM_CHECK);

		match = uvm_reg_field::type_id::create(match_string);
		match.configure(.parent							(this					),
							.size						(1						),
							.lsb_pos			    	(MIS_match_offset		),
							.access						("W1C"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(1						) );

		begin
			MIS_match_cb _MIS_match_cb = new("MIS_match_cb");
			uvm_reg_field_cb::add(match, _MIS_match_cb);
		end
		match.set_compare(UVM_CHECK);

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

//-------------------------------------------------------------------------------------
//
// CLASS: MIS_overflow_cb
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			MIS_overflow_cb is callback that is called after calling predict on MIS register that changes
//			corresponding values in register model
//
//
// SPECIFICATION:
//			if writing to MIS_overflow then MIS_overflow and RIS_overflow will change to 0 and
//			IIR will change to corresponding value
//
//-------------------------------------------------------------------------------------

class MIS_overflow_cb extends uvm_reg_cbs;

 `uvm_object_utils(MIS_overflow_cb)

 uvm_reg 		RIS_p, 			IIR_p;
 uvm_reg_field 	RIS_overflow_p, IIR_interrupt_priority_p;
 uvm_reg 		MIS_p;


	function new(input string name = "MIS_overflow_cb");
		super.new(name);
//		this.init();
	endfunction

	function void init(input uvm_reg_map map);
		MIS_p = map.get_reg_by_offset(MIS_address_offset);

	 	 RIS_p = map.get_reg_by_offset(RIS_address_offset);
		 $cast(RIS_overflow_p, RIS_p.get_field_by_name(overflow_string));

		 IIR_p = map.get_reg_by_offset(IIR_address_offset);
		 $cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(interrupt_priority_string));

	endfunction

 	virtual task post_write(uvm_reg_item rw);

 		write_extension extension;
		extension = write_extension::type_id::create("extension");

 		this.init(rw.map);

 		if (!($cast(extension, rw.extension)))
 			`uvm_error("CASTFAIL","Write extension not valid")

 		if(rw.extension != null) begin
 			if(extension.getOverflow()) begin
	 			if(IIR_interrupt_priority_p.value == 1)
					void'(IIR_interrupt_priority_p.predict(0));
					 
				if(RIS_overflow_p.value != 0)
					void'(RIS_overflow_p.predict(0));
			end
 		end

 	endtask : post_write
endclass

//-------------------------------------------------------------------------------------
//
// CLASS: MIS_underflow_cb
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			MIS_underflow_cb is callback that is called after calling predict on MIS register that changes
//			corresponding values in register model
//
//
// SPECIFICATION:
//			if writing to MIS_underflow then MIS_underflow and RIS_underflow will change to 0 and
//			IIR will change to corresponding value
//
//-------------------------------------------------------------------------------------

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
//		this.init();
	endfunction


	function void init(uvm_reg_map map);

		RIS_p = map.get_reg_by_offset(RIS_address_offset);
		$cast(RIS_underflow_p, RIS_p.get_field_by_name(underflow_string));

		IIR_p = map.get_reg_by_offset(IIR_address_offset);
		$cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(interrupt_priority_string));

		MIS_p = map.get_reg_by_offset(MIS_address_offset);
		$cast(MIS_overflow_p,MIS_p.get_field_by_name(overflow_string));


	endfunction

	virtual task post_write(uvm_reg_item rw);

		write_extension extension;
		extension = write_extension::type_id::create("extension");

 		this.init(rw.map);

 		if (!($cast(extension, rw.extension)))
 			`uvm_error("CASTFAIL","Write extension not valid")

		if(extension != null) begin
			if(extension.getUnderflow()) begin
	 			if(RIS_underflow_p.value == 1) begin
					if(RIS_underflow_p.value != 0)
						void'(RIS_underflow_p.predict(0));

					if(IIR_interrupt_priority_p.value < 3) begin
						if(MIS_overflow_p.value == 1)
							void'(IIR_interrupt_priority_p.predict(1));
						else
							void'(IIR_interrupt_priority_p.predict(0));		
					end
				end
			end
 		end

 	endtask : post_write
endclass

//-------------------------------------------------------------------------------------
//
// CLASS: MIS_match_cb
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			MIS_match_cb is callback that is called after calling predict on MIS register that changes
//			corresponding values in register model
//
//
// SPECIFICATION:
//			if writing to MIS_match then MIS_match and RIS_match will change to 0 and
//			IIR will change to corresponding value
//
//-------------------------------------------------------------------------------------

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
//		this.init();
	endfunction

	function void init(input uvm_reg_map map);

		RIS_p = map.get_reg_by_offset(RIS_address_offset);
		$cast(RIS_match_p, RIS_p.get_field_by_name(match_string));

		MIS_p = map.get_reg_by_offset(MIS_address_offset);
		$cast(MIS_match_p, MIS_p.get_field_by_name(match_string));
		$cast(MIS_overflow_p, MIS_p.get_field_by_name(overflow_string));
		$cast(MIS_underflow_p, MIS_p.get_field_by_name(underflow_string));

		IIR_p = map.get_reg_by_offset(IIR_address_offset);
		$cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(interrupt_priority_string));

	endfunction

	virtual task post_write(uvm_reg_item rw);
 		
 		write_extension extension;
		extension = write_extension::type_id::create("extension");

 		this.init(rw.map);

 		if (!($cast(extension, rw.extension)))
 			`uvm_error("CASTFAIL","Write extension not valid")

 		if(rw.extension != null) begin
 			if(extension.getMatch()) begin
		 		if(RIS_match_p.value != 0)
					void'(RIS_match_p.predict(0));

				if(MIS_underflow_p.value == 1)
					void'(IIR_interrupt_priority_p.predict(0));
				else if(MIS_overflow_p.value == 1)
					void'(IIR_interrupt_priority_p.predict(1));
				else
					void'(IIR_interrupt_priority_p.predict(0));
			end
		end
				
 	endtask : post_write

endclass


`endif