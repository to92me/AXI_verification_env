/******************************************************************************
	* DVT CODE TEMPLATE: sequence item
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_frame
//
//------------------------------------------------------------------------------

class axi_frame extends uvm_sequence_item;

	//Declare fields
	rand bit [ADDR_WIDTH-1 : 0]		addr;
	rand bit [7:0]					len;
	rand burst_size_enum			size;
	rand burst_type_enum			burst_type;
	rand lock_enum					lock;
	rand bit [ID_WIDTH-1 : 0]		id;
	rand bit [3:0]					cache;
	rand bit [2:0]					prot;
	rand bit [3:0]					qos;
	rand bit [3:0]					region;
	// user

	// constraints
	constraint c_lock {
		lock inside {NORMAL, EXCLUSIVE};
	}

	constraint c_burst_type {
		burst_type inside {FIXED, INCR, WRAP, Reserved};
	}

	constraint c_burst_size {
		size inside {BYTE_1, BYTE_2, BYTE_4, BYTE_8, BYTE_16, BYTE_32, BYTE_64, BYTE_128};
	}

	// UVM utility macros
	`uvm_object_utils_begin(axi_frame)
		`uvm_field_int(addr, UVM_DEFAULT)
		`uvm_field_int(len, UVM_DEFAULT)
		`uvm_field_enum(burst_size_enum, size, UVM_DEFAULT)
		`uvm_field_enum(burst_type_enum, burst_type, UVM_DEFAULT)
		`uvm_field_enum(lock_enum, lock, UVM_DEFAULT)
		`uvm_field_int(id, UVM_DEFAULT)
		`uvm_field_int(cache, UVM_DEFAULT)
		`uvm_field_int(prot, UVM_DEFAULT)
		`uvm_field_int(qos, UVM_DEFAULT)
		`uvm_field_int(region, UVM_DEFAULT)
		//`uvm_field_int(user, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "axi_frame");
		super.new(name);
	endfunction

endclass :  axi_frame
