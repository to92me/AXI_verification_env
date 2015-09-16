`ifndef DUT_REGISTER_MODEL_SVH
`define DUT_REGISTER_MODEL_SVH



//========================================== SPEC ===========================================================
//- RIS - bit 0 - overflow
//          - bit 1 - underflow
//          - registar je read-only, polja setuje hardver
//
//- IM - interrupt enable - bit 0 - overflow
//                                     - bit 1 - underflow
//                                     - ta dva polja su read-write, ostala su read-only
//
//- MIS - masked interrupt status - bit 0 - overflow
//                                                   - bit 1 - underflow
//
//- MIS ima i dodatnu funkcionalnost - upis 1 na odgovarajucu bit lokaciju brise flag i u RIS i u MIS registru; upis 0 ne radi nista
//
//- LOAD registar - 16bitna vrednost sa kojom se poredi brojac
//                           - registar je read-write
//
//- CFG registar - bit 0 - counter enable - enable-uje brojanje
//                        - bit 1 - up/down - vrednost 0 je up; vrednost 1 je down
//                        - polja su read-write, ostala su read-only
//
//- SWRESET registar - ispravan upis sifre 0x5a resetuje sve registre
//                                  - neispravan upis sifre ne radi nista
//                                  - citanjem registra dobija se vrednost 0
//===========================================================================================================

//							 ADDRESS  -    BIT
// RIS offset
`define RIS_address_offset 		'h0
`define RIS_underflow_offset 			 0
`define RIS_overflow_offset 			 1
`define RIS_match_offset 				 2
`define RIS_reserved_offest				 3

// IM offest
`define IM_address_offset 		'h2
`define IM_underflow_offest				 0
`define IM_overflow_offset 				 1
`define IM_match_offset 				 2
`define IM_reserved_offest				 3


// MIS offest
`define MIS_address_offset		'h4
`define MIS_underflow_offest			 0
`define MIS_overflow_offset 			 1
`define MIS_match_offset 				 2
`define MIS_reserved_offest				 3

// LOAD
`define LOAD_address_offset		'h6
`define LOAD_compare_offest 			 0

// CFG
`define CFG_address_offset 		'h8
`define CFG_counter_enable_offset 		 0
`define CFG_counter_direction_offset 	 1
`define CFG_reserved_offset 			 2

// SWRESET
`define SWRESET_address_offset	'h10
`define SWRESET_passcode_offset 		 0

//IIR
`define IIR_address_offset		'h12
`define IIR_interrupt_offset 			 0
`define IIR_reserved					 2

//MATCH
`define MATCH_address_offset 	'h14
`define MATCH_match_offest 				 0

//COUNT
`define COUNT_address_offset	'h16
`define COUNT_counter_offest 			 0


`define overflow_string 				"overflow"
`define underflow_string 				"underflow"
`define reserved_string					"reserved"
`define match_string 					"match"
`define compare_string 					"compare"
`define counter_string 					"counter"
`define counter_enable_string 			"counter_enable"
`define counter_direction_string		"counter_direction"
`define reset_passcode_string 			"reset_passcode"
`define interrupt_string				"interrupt_string"
`define interrupt_priority_string		"interrupt_priority"

`define map_name_string					"dut_register_map"
//
// ================================================================================================================
//
//											****REGISTER*****
//
// ================================================================================================================

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
		underflow = uvm_reg_field::type_id::create(`underflow_string);
		underflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(`RIS_underflow_offset	),
							.access						("RO"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

		overflow = uvm_reg_field::type_id::create(`overflow_string);
		overflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(`RIS_overflow_offset	),
							.access						("RO"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

		match = uvm_reg_field::type_id::create(`match_string);
		match.configure(.parent							(this					),
							.size						(1						),
							.lsb_pos			    	(`RIS_match_offset		),
							.access						("RO"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

		reserved = uvm_reg_field::type_id::create(`reserved_string);
		reserved.configure( .parent						(this					),
							.size						(13						),
							.lsb_pos			    	(`RIS_reserved_offest	),
							.access						("RO"					),
							.volatile					(0						),
							.reset						(0						),
							.has_reset					(0						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );
	endfunction
endclass

//============================== IM SPEC ==================================================
//- IM - interrupt enable - bit 0 - overflow
//                                     - bit 1 - underflow
//                                     - ta dva polja su read-write, ostala su read-only
// ne menja ga hardwer
//=========================================================================================

class IM extends uvm_reg;
	rand uvm_reg_field underflow;
	rand uvm_reg_field overflow;
	rand uvm_reg_field match;
	uvm_reg_field reserved;


	`uvm_object_utils(IM)



	// new - constructor
	function new (string name = "IM");
		super.new(.name(name), .nbits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build();
		underflow = uvm_reg_field::type_id::create(`underflow_string);
		underflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(`IM_underflow_offest	),
							.access						("RW"					),
							.volatile					(0						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

		overflow = uvm_reg_field::type_id::create(`overflow_string);
		overflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(`IM_overflow_offset	),
							.access						("RW"					),
							.volatile					(0						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

		match = uvm_reg_field::type_id::create(`match_string);
		match.configure(.parent							(this					),
							.size						(1						),
							.lsb_pos			    	(`IM_match_offset		),
							.access						("RW"					),
							.volatile					(0						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

		reserved = uvm_reg_field::type_id::create(`reserved_string);
		reserved.configure(.parent						(this					),
							.size						(13						),
							.lsb_pos			    	(`IM_reserved_offest	),
							.access						("RO"					),
							.volatile					(0						),
							.reset						(0						),
							.has_reset					(0						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );
	endfunction
endclass


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
		underflow = uvm_reg_field::type_id::create(`underflow_string);
		underflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(`MIS_underflow_offest	),
							.access						("RW"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );
		begin
			MIS_overflow_cb _MIS_overflow_cb = new("MIS_overflow_cb");
			uvm_reg_field_cb::add(_MIS_overflow_cb, underflow);
		end

		overflow = uvm_reg_field::type_id::create(`overflow_string);
		overflow.configure(.parent						(this					),
							.size						(1						),
							.lsb_pos			    	(`MIS_overflow_offset	),
							.access						("RW"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

		match = uvm_reg_field::type_id::create(`match_string);
		match.configure(.parent							(this					),
							.size						(1						),
							.lsb_pos			    	(`MIS_match_offset		),
							.access						("RW"					),
							.volatile					(1						),
							.reset						(1'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

		reserved = uvm_reg_field::type_id::create(`reserved_string);
		reserved.configure(.parent						(this					),
							.size						(13						),
							.lsb_pos			    	(`MIS_reserved_offest	),
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

 function void post_predict(input uvm_reg_field  fld,
                                      input uvm_reg_data_t previous,
                                      inout uvm_reg_data_t value,
                                      input uvm_predict_e  kind,
                                      input uvm_path_e     path,
                                      input uvm_reg_map    map);


	 RIS_p = map.get_mem_by_offset(`RIS_address_offset);
	 $cast(RIS_overflow_p, RIS_p.get_field_by_name(`overflow_string));

	 IIR_p = map.get_mem_by_offset(`IIR_address_offset);
	 $cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(`interrupt_priority_string));

	 if(kind == UVM_WRITE)
		 begin
			 if(value == 1)
				 begin

					// if previous value of MIS[2:0] is 000 then writing to 001
					//will change IIR
					if(fld.value == 0)
						 begin
							 IIR_interrupt_priority_p.predict(1);
						 end

					void'(RIS_overflow_p.predict(0));
					fld.predict(0);
					value = 0;
				 end
		 end

 endfunction
endclass

class MIS_underflow_cb extends uvm_reg_cbs;

 	`uvm_object_utils(MIS_underflow_cb)

 	uvm_reg 		RIS_p, 			 IIR_p;
 	uvm_reg_field 	RIS_underflow_p, IIR_interrupt_priority_p;

	function void post_predict(input uvm_reg_field  fld,
                                      input uvm_reg_data_t previous,
                                      inout uvm_reg_data_t value,
                                      input uvm_predict_e  kind,
                                      input uvm_path_e     path,
                                      input uvm_reg_map    map);


		RIS_p = map.get_mem_by_offset(`RIS_address_offset);
		$cast(RIS_underflow_p, RIS_p.get_field_by_name(`underflow_string));

		IIR_p = map.get_mem_by_offset(`IIR_address_offset);
		$cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(`underflow_string));

		if(kind == UVM_PREDICT_WRITE)
			begin
				if(value == 1)
					begin
						// if MISC = 00x then writing to MISC _1_ will change IIR to 2
						if(fld.value == 1)
							begin
								IIR_interrupt_priority_p.predict(2);
							end

						void'(RIS_underflow_p.predict(0));
						fld.predict(0);
						value = 0;
					end
			end
	endfunction
endclass


class MIS_match_cb extends uvm_reg_cbs;

 	`uvm_object_utils(MIS_match_cb)

 	uvm_reg 		RIS_p, 			 IIR_p;
 	uvm_reg_field 	RIS_match_p, IIR_interrupt_priority_p;

	function void post_predict(input uvm_reg_field  fld,
                                      input uvm_reg_data_t previous,
                                      inout uvm_reg_data_t value,
                                      input uvm_predict_e  kind,
                                      input uvm_path_e     path,
                                      input uvm_reg_map    map);


		RIS_p = map.get_mem_by_offset(`RIS_address_offset);
		$cast(RIS_match_p, RIS_p.get_field_by_name(`underflow_string));

		IIR_p = map.get_mem_by_offset(`IIR_address_offset);
		$cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(`underflow_string));

		if(kind == UVM_PREDICT_WRITE)
			begin
				if(value == 1)
					begin
						// if MISC = 00x then writing to MISC _1_ will change IIR to 2
						if(fld.value >= 3)
							begin
								IIR_interrupt_priority_p.predict(2);
							end


						void'(RIS_overflow_p.predict(0));
						fld.predict(0);
						value = 0;
					end
			end
	endfunction


endclass

//============================== LOAD SPEC ==================================================
//- LOAD registar - 16bitna vrednost sa kojom se poredi brojac
//                           - registar je read-write
//=========================================================================================

class LOAD extends uvm_reg;
 	rand uvm_reg_field compare;

	`uvm_object_utils(LOAD)

	// new - constructor
	function new (string name = "LOAD");
		super.new(.name(name), .nbits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new


	function void build();
		compare = uvm_reg_field::type_id::create(`compare_string);
		compare.configure(.parent						(this					),
							.size						(16						),
							.lsb_pos			    	(`LOAD_compare_offest	),
							.access						("RW"					),
							.volatile					(0						),
							.reset						(16'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

	endfunction
endclass

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
		super.new(.name(name), .nbits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build();
		counter_enable = uvm_reg_field::type_id::create(`counter_string);
		counter_enable.configure(.parent				(this						),
							.size						(1							),
							.lsb_pos			    	(`CFG_counter_enable_offset	),
							.access						("RW"						),
							.volatile					(0							),
							.reset						(1'b0						),
							.has_reset					(1							),
							.is_rand					(0							),
							.individually_accessible 	(0							) );


		direction = uvm_reg_field::type_id::create("direction");
		direction.configure(.parent						(this						),
							.size						(1							),
							.lsb_pos			    	(`CFG_counter_direction_offset),
							.access						("RW"						),
							.volatile					(0							),
							.reset						(1'b0						),
							.has_reset					(1							),
							.is_rand					(0							),
							.individually_accessible 	(0							) );

		reserved = uvm_reg_field::type_id::create("reserved");
		reserved.configure( .parent						(this						),
							.size						(14							),
							.lsb_pos			    	(`CFG_reserved_offset		),
							.access						("RO"						),
							.volatile					(0							),
							.reset						(0							),
							.has_reset					(0							),
							.is_rand					(0							),
							.individually_accessible 	(0							) );
	endfunction
endclass

//============================== SWRESET SPEC ==================================================
//- SWRESET registar - ispravan upis sifre 0x5a resetuje sve registre
//                                  - neispravan upis sifre ne radi nista
//                                  - citanjem registra dobija se vrednost 0
//===========================================================================================

class SWRESET extends uvm_reg;
	rand uvm_reg_field reset_passcode;

	`uvm_object_utils(SWRESET)

	function new (string name = "SWRESET");
		super.new(.name(name), .nbits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction

	function void build();
	reset_passcode = uvm_reg_field::type_id::create(`reset_passcode_string);
		reset_passcode.configure(.parent				(this					),
							.size						(16						),
							.lsb_pos			    	(`SWRESET_passcode_offset),
							.access						("RW"					),
							.volatile					(0						),
							.reset						(16'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );
	endfunction

endclass

//============================== IIR SPEC ==================================================
//- interrupt index registar - registar prioriteta - npr u slucaju da je bit 0 u MIS aktivan, ovaj registar bi imao vrednost 1
//                                                                       - u slucaju da je bit 1 u MIS aktivan, ovaj registar bi imao vrednost 2
//                                                                       - u slucaju da je bit 0 i 1 u MIS aktivan, ovaj registar bi opet imao vrednost 2, znaci bit 1 bi se
//                                                                               proglasio za interrupt viseg prioriteta
//===========================================================================================


class IIR extends uvm_reg;
	rand uvm_reg_field interrupt_priority;
	uvm_reg_field reserved;

	`uvm_object_utils(IIR)

	function new (string name = "IIR");
		super.new(.name(name), .nbits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction

	function void build();
	interrupt = uvm_reg_field::type_id::create(`interrupt_priority_string);
	interrupt.configure(	.parent						(this					),
							.size						(2						),
							.lsb_pos			    	(`IIR_interrupt_offset	),
							.access						("R0"					),
							.volatile					(1						),
							.reset						(2'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

	reserved = uvm_reg_field::type_id::create(`reserved_string);
	reserved.configure(		.parent						(this					),
							.size						(14						),
							.lsb_pos			    	(`IIR_reserved			),
							.access						("R0"					),
							.volatile					(0						),
							.reset						(0						),
							.has_reset					(0						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );

	endfunction

endclass

//============================== MATCH SPEC ==================================================
//
//- match registar i match interrupt - u registar bi bila upisana neka vrednost - kad brojac dostigne tu vrednost, generisao bi se interrupt//
//
//===========================================================================================

class MATCH extends uvm_reg;
	rand uvm_reg_field match;

	`uvm_object_utils(MATCH)

	function new (string name = "MATCH");
		super.new(.name(name), .nbits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction

	function void build();
	match = uvm_reg_field::type_id::create(`match_string);
		match.configure(	.parent						(this					),
							.size						(16						),
							.lsb_pos			    	(`MATCH_match_offest	),
							.access						("RW"					),
							.volatile					(0						),
							.reset						(16'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );
	endfunction

endclass

//============================== COUNTER ==================================================
//
//
//===========================================================================================

class COUNT extends uvm_reg;
	uvm_reg_field counter;

	`uvm_object_utils(COUNT)

	function new (string name = "COUNT");
		super.new(.name(name), .nbits(16), .has_coverage(UVM_NO_COVERAGE));
	endfunction

	function void build();
	counter = uvm_reg_field::type_id::create(`counter_string);
		counter.configure(	.parent						(this					),
							.size						(16						),
							.lsb_pos			    	(`COUNT_counter_offest	),
							.access						("RO"					),
							.volatile					(1						),
							.reset						(16'b0					),
							.has_reset					(1						),
							.is_rand					(0						),
							.individually_accessible 	(0						) );
	endfunction

endclass

// =========================================REGISTER END =========================================================



// ================================================================================================================
//
//											****MEMORY*****
//
// ================================================================================================================

class dut_register_block extends uvm_reg_block;

	`uvm_object_utils(dut_register_block)

	rand RIS	 	RIS_reg;
	rand IM 		IM_reg;
	rand MIS 		MIS_reg;
	rand LOAD 		LOAD_reg;
	rand CFG 		CFG_reg;
	rand SWRESET	SWRESET_reg;
	rand IIR 		IIR_reg;
	rand MATCH 		MATCH_reg;
	rand COUNT		COUNT_reg;

	uvm_reg_map dut_map;


	function new(string name = "dut_register_block");
		super.new(name, UVM_NO_COVERAGE);
	endfunction

	function void build();
		RIS_reg = RIS::type_id::create("RIS");
		RIS_reg.configure(this,null,"");
		RIS_reg.build();

		IM_reg = IM::type_id::create("IM");
		IM_reg.configure(this,null,"");
		IM_reg.build();

		MIS_reg = MIS::type_id::create("MIS");
		MIS_reg.configure(this,null,"");
		MIS_reg.build();

		LOAD_reg = LOAD::type_id::create("LOAD");
		LOAD_reg.configure(this,null,"");
		LOAD_reg.build();

		CFG_reg = CFG::type_id::create("CFG");
		CFG_reg.configure(this,null,"");
		CFG_reg.build();

		SWRESET_reg = SWRESET::type_id::create("SWRESET");
		SWRESET_reg.configure(this,null,"");
		SWRESET_reg.build();

		IIR_reg = IIR::type_id::create("IIR");
		IIR_reg.configure(this,null,"");
		IIR_reg.build();

		MATCH_reg = MATCH::type_id::create("MATCH");
		MATCH_reg.configure(this,null,"");
		MATCH_reg.build();

		COUNT_reg = COUNT::type_id::create("COUNT");
		COUNT_reg.configure(this,null,"");
		COUNT_reg.build();

		dut_map = create_map(	.name			("dut"		),
								.base_addr		('h0			),
								.n_bytes		(2				),
								.byte_addressing(0				),
								.endian			(UVM_BIG_ENDIAN	)	);


		dut_map.add_reg(RIS_reg, 	`RIS_address_offset, 	"RO");
		dut_map.add_reg(IM_reg,	 	`IM_address_offset, 	"RW");
		dut_map.add_reg(MIS_reg,	`MIS_address_offset, 	"RW");
		dut_map.add_reg(LOAD_reg,	`LOAD_address_offset, 	"RW");
		dut_map.add_reg(CFG_reg,	`CFG_address_offset, 	"RW");
		dut_map.add_reg(SWRESET_reg,`SWRESET_address_offset,"RW");
		dut_map.add_reg(IIR_reg,	`IIR_address_offset,	"RO");
		dut_map.add_reg(MATCH_reg,	`MATCH_address_offset,	"RW");
		dut_map.add_reg(COUNT_reg,	`COUNT_address_offset,	"RO");

		// this is final configuration so lock it
		lock_model();

	endfunction

endclass
`endif

