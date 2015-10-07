`ifndef DUT_REGISTER_MODEL_SVH_
`define DUT_REGISTER_MODEL_SVH_


/**
* Project : DUT_ register model
*
* File : register_block.sv
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
* Description :dut_register_block
*
*
**/

//-------------------------------------------------------------------------------------
//
// CLASS: dut_register_block
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			this class is complete uvm register model that represents complete model of
//			DUT registers
//-------------------------------------------------------------------------------------



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

		dut_map = create_map(	.name			(map_name_string	),
								.base_addr		('h0				),
								.n_bytes		(4					),
								.byte_addressing(0					),
								.endian			(UVM_BIG_ENDIAN		)	);


		dut_map.add_reg(RIS_reg, 	RIS_address_offset, 	"RO");
		dut_map.add_reg(IM_reg,	 	IM_address_offset, 		"RW");
		dut_map.add_reg(MIS_reg,	MIS_address_offset, 	"RW");
		dut_map.add_reg(LOAD_reg,	LOAD_address_offset, 	"RW");
		dut_map.add_reg(CFG_reg,	CFG_address_offset, 	"RW");
		dut_map.add_reg(SWRESET_reg,SWRESET_address_offset,	"RW");
		dut_map.add_reg(IIR_reg,	IIR_address_offset,		"RO");
		dut_map.add_reg(MATCH_reg,	MATCH_address_offset,	"RW");
		dut_map.add_reg(COUNT_reg,	COUNT_address_offset,	"RO");
		dut_map.set_check_on_read(1);
		// this is final configuration so lock it
		lock_model();

	endfunction

endclass
`endif

