`ifndef DUT_REGISTER_MODEL_REFERECE_MODEL_SVH
`define DUT_REGISTER_MODEL_REFERECE_MODEL_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

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


class dut_referece_model extends uvm_component;


	dut_register_block  dut_register_model;

	event clock;
	int clock_frek;
	uvm_reg_map 	dut_register_map;

	uvm_reg MATCH_p;
	uvm_reg	SWRESET_p;
	uvm_reg COUNTER_p;
	uvm_reg CFG_p;

	uvm_reg RIS_p;
	uvm_reg MIS_p;
	uvm_reg IM_p;
	uvm_reg IIR_p;


	uvm_reg_field CFG_counter_enable_p;
	uvm_reg_field CFG_direction_p;


	uvm_reg_field RIS_overflow_p;
	uvm_reg_field RIS_underflow_p;
	uvm_reg_field RIS_match_p;

	uvm_reg_field MIS_overflow_p;
	uvm_reg_field MIS_underflow_p;
	uvm_reg_field MIS_match_p;

	uvm_reg_field IM_overflow_p;
	uvm_reg_field IM_underflow_p;
	uvm_reg_field IM_match_p;

	uvm_reg_field IIR_interrupt_priority_p;

	uvm_reg_field MATCH_compare_p;


`uvm_component_utils_begin(dut_referece_model)
	 `uvm_field_int(RIS, UVM_DEFAULT)
	 `uvm_field_int(IM, UVM_DEFAULT)
	 `uvm_field_int(MIS, UVM_DEFAULT)
	 `uvm_field_int(LOAD, UVM_DEFAULT)
	 `uvm_field_int(CFG, UVM_DEFAULT)
	 `uvm_field_int(SWRESET, UVM_DEFAULT)
	 `uvm_field_int(IIR, UVM_DEFAULT)
	 `uvm_field_int(MATCH, UVM_DEFAULT)
	 `uvm_field_int(COUNT, UVM_DEFAULT)
 `uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern task main();
	extern task clockGenerator();
	extern task refereceModelMain();
	extern task init();

endclass : dut_referece_model

	task dut_referece_model::main();
		this.init();
	    fork
		    this.clockGenerator();
		    this.refereceModelMain();
	    join
	endtask

	task dut_referece_model::clockGenerator();
		forever begin
		#clock_frek
		->clock;
		end
	endtask

	task dut_referece_model::refereceModelMain();
		bit[15 : 0] internal_counter;
		forever begin
			@clock;
			if(CFG_counter_enable_p.value == 1)
				begin
					case(CFG_direction_p)

// UP DIRECTION
						0:
						begin
							internal_counter++;
							if(internal_counter == 0)
								begin
									void'(RIS_overflow_p.predict(1));
									if(IM_overflow_p.value == 1)
										MIS_overflow_p.predict(1);
									if(IIR_interrupt_priority_p < 2)
										IIR_interrupt_priority_p.predict(2);
								end

							if(internal_counter == MATCH_compare_p.value)
								begin
									void'(RIS_match_p.predict(1));
									if(IM_match_p.value == 1)
										MIS_match_p.predict(1);
									IIR_interrupt_priority_p.predict(3);
								end
						end

// DOWN DIRECTION

						1:
						begin
							internal_counter--;
							if(internal_counter == 'hffff)
								begin
									void'(RIS_underflow_p.predict(1));
									if(IM_underflow_p.value == 1)
										MIS_underflow_p.predict(1);
									if(IIR_interrupt_priority_p < 1 )
										IIR_interrupt_priority_p.predict(1);
								end

							if(internal_counter == MATCH_compare_p.value)
								begin
									void'(RIS_match_p.predict(1));
									if(IM_match_p.value == 1)
										MIS_match_p.predict(1);
									IIR_interrupt_priority_p.predict(3);
								end

						end
					endcase

				end // if counter_enable == 1 end
		end // foreve begin end
	endtask

	task dut_referece_model::init();
		dut_register_map = 	dut_register_model.get_default_map();

		SWRESET_p 	= dut_register_map.get_reg_by_offset(`SWRESET_address_offset);

		COUNTER_p 	= dut_register_map.get_reg_by_offset(`COUNT_address_offset);

		CFG_p		= dut_register_map.get_reg_by_offset(`CFG_address_offset);
		$cast(CFG_counter_enable_p,	 	CFG_p.get_field_by_name(`counter_enable_string));
		$cast(CFG_direction_p, 			CFG_p.get_field_by_name(`counter_direction_string));

		RIS_p		= dut_register_map.get_reg_by_offset(`RIS_address_offset);
		$cast(RIS_overflow_p,	RIS_p.get_field_by_name(`overflow_string));
		$cast(RIS_underflow_p, 	RIS_p.get_field_by_name(`underflow_string));
		$cast(RIS_match_p,		RIS_p.get_field_by_name(`match_string));

		MIS_p		= dut_register_map.get_reg_by_offset(`MIS_address_offset);
		$cast(MIS_overflow_p, 	MIS_p.get_field_by_name(`overflow_string));
		$cast(MIS_underflow_p, 	MIS_p.get_field_by_name(`underflow_string));
		$cast(MIS_match_p,		MIS_p.get_field_by_name(`match_string));


		IM_p		= dut_register_map.get_reg_by_offset(`IM_address_offset);
		$cast(IM_overflow_p, 	IM_p.get_field_by_name(`underflow_string));
		$cast(IM_underflow_p, 	IM_p.get_field_by_name(`overflow_string));
		$cast(IM_match_p,		IM_p.get_field_by_name(`match_string));

		IIR_p 		= dut_register_map.get_reg_by_offset(`IIR_address_offset);
		$cast(IIR_interrupt_priority_p, IIR_p.get_field_by_name(`interrupt_priority_string));

		MATCH_p		= dut_register_map.get_reg_by_offset(`MATCH_address_offset);
		$cast(MATCH_compare_p, MATCH_p.get_field_by_name(`compare_string));

	endtask


`endif