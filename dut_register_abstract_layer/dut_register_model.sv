`ifndef DUT_REGISTER_MODEL
`define DUT_REGISTER_MODEL



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
		super.new(.name(name), .nbits(32), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build();
		underflow = uvm_reg_field::type_id::create("underflow");
		underflow.configure(.parent						(this	),
							.size						(1		),
							.lsb_pos			    	(0		),
							.access						("RO"	),
							.volatile					(1		),
							.reset						(1'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

		overflow = uvm_reg_field::type_id::create("overflow");
		overflow.configure(.parent						(this	),
							.size						(1		),
							.lsb_pos			    	(1		),
							.access						("RO"	),
							.volatile					(1		),
							.reset						(1'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

		match = uvm_reg_field::type_id::create("match");
		match.configure(.parent							(this	),
							.size						(1		),
							.lsb_pos			    	(2		),
							.access						("RO"	),
							.volatile					(1		),
							.reset						(1'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

		reserved = uvm_reg_field::type_id::create("reserved");
		reserved.configure( .parent						(this	),
							.size						(29		),
							.lsb_pos			    	(3		),
							.access						("RO"	),
							.volatile					(0		),
							.reset						(0		),
							.has_reset					(0		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );
	endfunction
endclass

//============================== IM SPEC ==================================================
//- IM - interrupt enable - bit 0 - overflow
//                                     - bit 1 - underflow
//                                     - ta dva polja su read-write, ostala su read-only
//=========================================================================================

class IM extends uvm_reg;
	rand uvm_reg_field underflow;
	rand uvm_reg_field overflow;
	rand uvm_reg_field match;
	uvm_reg_field reserved;


	`uvm_object_utils(IM)



	// new - constructor
	function new (string name = "IM");
		super.new(.name(name), .nbits(32), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build();
		underflow = uvm_reg_field::type_id::create("underflow");
		underflow.configure(.parent						(this	),
							.size						(1		),
							.lsb_pos			    	(0		),
							.access						("RW"	),
							.volatile					(1		),
							.reset						(1'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

		overflow = uvm_reg_field::type_id::create("overflow");
		overflow.configure(.parent						(this	),
							.size						(1		),
							.lsb_pos			    	(1		),
							.access						("RW"	),
							.volatile					(1		),
							.reset						(1'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

		match = uvm_reg_field::type_id::create("match");
		match.configure(.parent							(this	),
							.size						(1		),
							.lsb_pos			    	(2		),
							.access						("RW"	),
							.volatile					(1		),
							.reset						(1'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

		reserved = uvm_reg_field::type_id::create("reserved");
		reserved.configure(.parent						(this	),
							.size						(29		),
							.lsb_pos			    	(3		),
							.access						("RO"	),
							.volatile					(0		),
							.reset						(0		),
							.has_reset					(0		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );
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
		super.new(.name(name), .nbits(32), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build();
		underflow = uvm_reg_field::type_id::create("underflow");
		underflow.configure(.parent						(this	),
							.size						(1		),
							.lsb_pos			    	(0		),
							.access						("RW"	),
							.volatile					(1		),
							.reset						(1'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

		overflow = uvm_reg_field::type_id::create("overflow");
		overflow.configure(.parent						(this	),
							.size						(1		),
							.lsb_pos			    	(1		),
							.access						("RW"	),
							.volatile					(1		),
							.reset						(1'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

		match = uvm_reg_field::type_id::create("match");
		match.configure(.parent							(this	),
							.size						(1		),
							.lsb_pos			    	(2		),
							.access						("RW"	),
							.volatile					(1		),
							.reset						(1'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

		reserved = uvm_reg_field::type_id::create("reserved");
		reserved.configure(.parent						(this	),
							.size						(29		),
							.lsb_pos			    	(3		),
							.access						("RO"	),
							.volatile					(0		),
							.reset						(0		),
							.has_reset					(0		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );
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
		compare = uvm_reg_field::type_id::create("compare");
		compare.configure(.parent						(this	),
							.size						(16		),
							.lsb_pos			    	(0		),
							.access						("RW"	),
							.volatile					(0		),
							.reset						(16'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

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
		super.new(.name(name), .nbits(32), .has_coverage(UVM_NO_COVERAGE));
	endfunction : new

	function void build();
		counter_enable = uvm_reg_field::type_id::create("counter_enable");
		counter_enable.configure(.parent				(this	),
							.size						(1		),
							.lsb_pos			    	(0		),
							.access						("RW"	),
							.volatile					(0		),
							.reset						(1'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );


		direction = uvm_reg_field::type_id::create("direction");
		direction.configure(.parent						(this	),
							.size						(1		),
							.lsb_pos			    	(1		),
							.access						("RW"	),
							.volatile					(0		),
							.reset						(1'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

		reserved = uvm_reg_field::type_id::create("reserved");
		reserved.configure( .parent						(this	),
							.size						(16		),
							.lsb_pos			    	(3		),
							.access						("RO"	),
							.volatile					(0		),
							.reset						(0		),
							.has_reset					(0		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );
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
		super.new(.name(name), .nbits(32), .has_coverage(UVM_NO_COVERAGE));
	endfunction

	function void build();
	reset_passcode = uvm_reg_field::type_id::create("reset_passcode");
		reset_passcode.configure(.parent				(this	),
							.size						(32		),
							.lsb_pos			    	(0		),
							.access						("RW"	),
							.volatile					(0		),
							.reset						(32'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );
	endfunction

endclass

//============================== IIR SPEC ==================================================
//- interrupt index registar - registar prioriteta - npr u slucaju da je bit 0 u MIS aktivan, ovaj registar bi imao vrednost 1
//                                                                       - u slucaju da je bit 1 u MIS aktivan, ovaj registar bi imao vrednost 2
//                                                                       - u slucaju da je bit 0 i 1 u MIS aktivan, ovaj registar bi opet imao vrednost 2, znaci bit 1 bi se
//                                                                               proglasio za interrupt viseg prioriteta
//===========================================================================================


class IIR extends uvm_reg;
	rand uvm_reg_field interrupt;
	uvm_reg_field reserved;

	`uvm_object_utils(IIR)

	function new (string name = "IIR");
		super.new(.name(name), .nbits(32), .has_coverage(UVM_NO_COVERAGE));
	endfunction

	function void build();
	interrupt = uvm_reg_field::type_id::create("interrupt");
	interrupt.configure(	.parent						(this	),
							.size						(2		),
							.lsb_pos			    	(0		),
							.access						("RW"	),
							.volatile					(1		),
							.reset						(2'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

	reserved = uvm_reg_field::type_id::create("reserved");
	reserved.configure(		.parent						(this	),
							.size						(30		),
							.lsb_pos			    	(0		),
							.access						("RW"	),
							.volatile					(0		),
							.reset						(0		),
							.has_reset					(0		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );

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
		super.new(.name(name), .nbits(32), .has_coverage(UVM_NO_COVERAGE));
	endfunction

	function void build();
	match = uvm_reg_field::type_id::create("match");
		match.configure(	.parent						(this	),
							.size						(32		),
							.lsb_pos			    	(0		),
							.access						("RW"	),
							.volatile					(0		),
							.reset						(32'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );
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
		super.new(.name(name), .nbits(32), .has_coverage(UVM_NO_COVERAGE));
	endfunction

	function void build();
	counter = uvm_reg_field::type_id::create("counter");
		counter.configure(	.parent						(this	),
							.size						(32		),
							.lsb_pos			    	(0		),
							.access						("RO"	),
							.volatile					(1		),
							.reset						(32'b0	),
							.has_reset					(1		),
							.is_rand					(0		),
							.individually_accessible 	(0		) );
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

		dut_map = create_map("Counter", 'h0, ADDR_WIDTH, ADDR_WIDTH/8, 1);

		dut_map.add_reg(RIS_reg, 	'h0, "RO");
		dut_map.add_reg(IM_reg,	 	'h2, "RW");
		dut_map.add_reg(MIS_reg,	'h4, "RW");
		dut_map.add_reg(LOAD_reg,	'h6, "RW");
		dut_map.add_reg(CFG_reg,	'h8, "RO");
		dut_map.add_reg(SWRESET_reg,'h10,"RW");
		dut_map.add_reg(IIR_reg,	'h12,"RW");
		dut_map.add_reg(MATCH_reg,	'h14,"RW");
		dut_map.add_reg(COUNT_reg,	'h16,"RO");

		// this is final configuration so lock it
		lock_model();

	endfunction

endclass
`endif

