`ifndef DUT_REGISTER_MODEL_TYPES_SVH
`define DUT_REGISTER_MODEL_TYPES_SVH


	// RIS parameters
	parameter RIS_address_offset  		=	'h0;
	parameter RIS_underflow_offset 				 		= 1;
	parameter RIS_overflow_offset						= 0;
	parameter RIS_match_offset							= 2;
	parameter RIS_reserved_offest						= 3;

	// IM parameters
	parameter IM_address_offset  		=	'h2;
	parameter IM_underflow_offest 				 		= 1;
	parameter IM_overflow_offset						= 0;
	parameter IM_match_offset							= 2;
	parameter IM_reserved_offest						= 3;


	//MIS parameters
	parameter MIS_address_offset  		=	'h4;
	parameter MIS_underflow_offest 				 		= 1;
	parameter MIS_overflow_offset						= 0;
	parameter MIS_match_offset							= 2;
	parameter MIS_reserved_offest						= 3;


	//LOAD parameters
	parameter LOAD_address_offset  		=	'h6;
	parameter LOAD_compare_offest 				 		= 0;


	//CFG parameters
	parameter CFG_address_offset 		=	'h8;
	parameter CFG_counter_enable_offset 				= 0;
	parameter CFG_counter_direction_offset 	 			= 1;
	parameter CFG_reserved_offset 			  			= 2;

	// SWRESET paramters
	parameter SWRESET_address_offset	= 	'hA;
	parameter SWRESET_passcode_offset 		 			= 0;


	//IIR paramters
	parameter IIR_address_offset		=	'hC;
	parameter IIR_interrupt_offset 						= 0;
	parameter IIR_reserved					 			= 2;


	//MATCH
	parameter MATCH_address_offset 		=	'hE;
	parameter MATCH_match_offest 						= 0;


	//COUNT
	parameter COUNT_address_offset		=	'h10;
	parameter COUNT_counter_offest 						= 0;


	parameter overflow_string 				= "overflow";
	parameter underflow_string 				= "underflow";
	parameter reserved_string				= "reserved";
	parameter match_string 					= "match";
	parameter compare_string 				= "compare";
	parameter counter_string 				= "counter";
	parameter counter_enable_string 		= "counter_enable";
	parameter counter_direction_string		= "counter_direction";
	parameter reset_passcode_string 		= "reset_passcode";
	parameter interrupt_string				= "interrupt_string";
	parameter interrupt_priority_string		= "interrupt_priority";

	parameter map_name_string				= "dut_register_map";



`endif