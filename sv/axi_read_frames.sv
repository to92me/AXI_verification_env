/******************************************************************************
	* DVT CODE TEMPLATE: sequence item
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

`ifndef AXI_READ_FRAMES_SVH
`define AXI_READ_FRAMES_SVH

//------------------------------------------------------------------------------
//
// CLASS: axi_read_base_frame
//
//------------------------------------------------------------------------------
class axi_read_base_frame extends uvm_sequence_item;

	bit [ID_WIDTH-1 : 0]	id;

	// control
	valid_enum 				valid;

	`uvm_object_utils_begin(axi_read_base_frame)
		`uvm_field_int(id, UVM_DEFAULT)
		`uvm_field_enum(valid_enum, valid, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "axi_read_single_frame");
		super.new(name);
	endfunction

endclass : axi_read_base_frame

//------------------------------------------------------------------------------
//
// CLASS: axi_read_single_frame
//
//------------------------------------------------------------------------------
class axi_read_single_frame extends axi_read_base_frame;

	//Declare fields
	rand bit [DATA_WIDTH-1 : 0]	data;
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
		`uvm_field_int(last, UVM_DEFAULT)
		`uvm_field_int(delay, UVM_DEFAULT)
		`uvm_field_enum(last_enum, last_mode, UVM_DEFAULT)
		//`uvm_field_int(user, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "axi_read_single_frame");
		super.new(name);
	endfunction

endclass :  axi_read_single_frame

//------------------------------------------------------------------------------
//
// CLASS: axi_read_burst_frame
//
//------------------------------------------------------------------------------
class axi_read_burst_frame extends axi_read_base_frame;

	rand bit [ADDR_WIDTH-1 : 0]		addr;
	rand bit [7:0]					len;
	rand burst_size_enum			size;
	rand burst_type_enum			burst_type;
	rand lock_enum					lock;
	rand bit [3:0]					cache;
	rand bit [2:0]					prot;
	rand bit [3:0]					qos;
	rand bit [3:0]					region;
	// user

	// UVM utility macros
	`uvm_object_utils_begin(axi_read_burst_frame)
		`uvm_field_int(addr, UVM_DEFAULT)
		`uvm_field_int(len, UVM_DEFAULT)
		`uvm_field_enum(burst_size_enum, size, UVM_DEFAULT)
		`uvm_field_enum(burst_type_enum, burst_type, UVM_DEFAULT)
		`uvm_field_enum(lock_enum, lock, UVM_DEFAULT)
		`uvm_field_int(cache, UVM_DEFAULT)
		`uvm_field_int(prot, UVM_DEFAULT)
		`uvm_field_int(qos, UVM_DEFAULT)
		`uvm_field_int(region, UVM_DEFAULT)
		// `uvm_field_int(user, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "axi_frame");
		super.new(name);
	endfunction

endclass : axi_read_burst_frame

`endif