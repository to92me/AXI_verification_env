`ifndef DUT_REGISTER_MODEL_SVH_
`define DUT_REGISTER_MODEL_SVH_



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
//											****REG_BLOCK*****
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

		dut_map = create_map(	.name			(`map_name_string	),
								.base_addr		('h0				),
								.n_bytes		(2					),
								.byte_addressing(0					),
								.endian			(UVM_BIG_ENDIAN		)	);


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

