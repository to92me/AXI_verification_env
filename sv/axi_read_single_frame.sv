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
	lock_enum					lock;
	bit							read_last;
	rand bit [2:0]				delay;
	// user

	// constraints
	constraint c_lock {
		lock inside {NORMAL, EXCLUSIVE};
	}

	// UVM utility macros
	`uvm_object_utils_begin(axi_read_single_frame)
		`uvm_field_int(data, UVM_DEFAULT)
		`uvm_field_enum(lock_enum, lock, UVM_DEFAULT)
		`uvm_field_int(id, UVM_DEFAULT)
		`uvm_field_int(read_last, UVM_DEFAULT)
		`uvm_field_int(delay, UVM_DEFAULT)
		//`uvm_field_int(user, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "axi_read_single_frame");
		super.new(name);
	endfunction

endclass :  axi_read_single_frame