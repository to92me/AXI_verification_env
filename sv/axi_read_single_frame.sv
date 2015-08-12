/******************************************************************************
	* DVT CODE TEMPLATE: sequence item
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_read_single_frame
//
//------------------------------------------------------------------------------

class axi_read_single_frame extends uvm_sequence_item;

	//Declare fields
	rand bit [DATA_WIDTH-1 : 0]	data;
	bit [ID_WIDTH-1 : 0]		id;
	rand response_enum			resp;
	bit							last;
	// user

	// control
	rand bit [2:0]				delay;
	rand last_enum				last_mode;

	constraint default_last_bit {last_mode dist {GOOD_LAST_BIT := 80, BAD_LAST_BIT := 20};}

	// UVM utility macros
	`uvm_object_utils_begin(axi_read_single_frame)
		`uvm_field_int(data, UVM_DEFAULT)
		`uvm_field_enum(response_enum, resp, UVM_DEFAULT)
		`uvm_field_int(id, UVM_DEFAULT)
		`uvm_field_int(last, UVM_DEFAULT)
		`uvm_field_int(delay, UVM_DEFAULT)
		`uvm_field_enum(last_enum, last_mode, UVM_DEFAULT)
		//`uvm_field_int(user, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "axi_read_single_frame");
		super.new(name);
	endfunction

endclass :  axi_read_single_frame