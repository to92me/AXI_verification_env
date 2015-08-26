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

	rand bit [ID_WIDTH-1 : 0]	id;

	// control
	valid_enum 				valid;
	rand bit [2:0]			delay;

	`uvm_object_utils_begin(axi_read_base_frame)
		`uvm_field_int(id, UVM_DEFAULT)
		`uvm_field_enum(valid_enum, valid, UVM_DEFAULT)
		`uvm_field_int(delay, UVM_DEFAULT)
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
	rand last_enum				last_mode;
	err_enum					err;

	//constraint default_last_bit {last_mode dist {GOOD_LAST_BIT := 80, BAD_LAST_BIT := 20};}
	constraint default_last_bit {last_mode == GOOD_LAST_BIT;}	// TODO : put back to dist

	// UVM utility macros
	`uvm_object_utils_begin(axi_read_single_frame)
		`uvm_field_int(data, UVM_DEFAULT)
		`uvm_field_enum(response_enum, resp, UVM_DEFAULT)
		`uvm_field_int(last, UVM_DEFAULT)
		`uvm_field_enum(last_enum, last_mode, UVM_DEFAULT)
		`uvm_field_enum(err_enum, err, UVM_DEFAULT)
		//`uvm_field_int(user, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "axi_read_single_frame");
		super.new(name);
	endfunction

	function void calc_resp(lock_enum slave_lock, lock_enum burst_lock);
		if ((burst_lock == EXCLUSIVE) && (slave_lock == NORMAL)) begin
			this.resp = OKAY;
			this.err = ERROR;
		end
		else if (burst_lock == EXCLUSIVE) begin
			this.resp = EXOKAY;
			this.err = NO_ERROR;
		end
		else begin
			this.resp = OKAY;
			this.err = NO_ERROR;
		end
	endfunction : calc_resp

	function bit calc_last_bit(bit last, last_enum mode);
		if(mode == BAD_LAST_BIT)
			return ~last;
		else
			return last;
	endfunction : calc_last_bit

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

	constraint default_delay {delay < 5;}

	// constrain number of bytes in a transfer
	constraint default_burst_size {size <= $clog2(DATA_WIDTH / 8);}

	// burst length for the INCR type can be 1 - 256, for others 1 - 16
	// for a wrapping burst, length must be 2, 4, 8 or 16
	constraint default_len {
		len > 0;
		if (burst_type == FIXED) {
			len <= 16;
		}
		else if (burst_type == WRAP) {
			len inside {2, 4, 8, 16};
		}
	}
	constraint order_type {solve burst_type before len;}	// because of default_len constraint

	// for a wrapping burst the start address must be aligned to the size of each transfer
	constraint default_burst_type {
		// TODO : ovde bi trebalo $floor umesto int' tj rounded down
		// ali mislim da i ovako radi jer ja samo hocu da znam da li adresa poravnata ili nije
		// a ne zanima me koliko iznosi poravnata adresa - PROVERITI
		if (addr == ((int'(addr/(2**size)))*(2**size))) {
			burst_type inside {FIXED, INCR, WRAP};
		}
		else {	// address not aligned
			burst_type inside {FIXED, INCR};
		}
		// never use Reserved
	}
	constraint order_addr {solve addr before burst_type;}
	constraint order_size {solve size before burst_type;}

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

	function new (string name = "axi_read_burst_frame");
		super.new(name);
	endfunction

endclass : axi_read_burst_frame

//------------------------------------------------------------------------------
//
// CLASS: axi_read_whole_burst
//
//------------------------------------------------------------------------------
class axi_read_whole_burst extends axi_read_burst_frame;

	axi_read_single_frame single_frames[$];

	`uvm_object_utils_begin(axi_read_whole_burst)
		//`uvm_field_queue_int(single_frames, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "axi_read_whole_burst");
		super.new(name);
	endfunction

endclass : axi_read_whole_burst

//------------------------------------------------------------------------------
//
// CLASS: axi_read_whole_burst
//
//------------------------------------------------------------------------------
class axi_read_single_addr extends axi_read_single_frame;

	bit [ADDR_WIDTH-1 : 0]	addr;

	`uvm_object_utils_begin(axi_read_single_addr)
		`uvm_field_int(addr, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "axi_read_single_addr");
		super.new(name);
	endfunction

endclass : axi_read_single_addr

`endif