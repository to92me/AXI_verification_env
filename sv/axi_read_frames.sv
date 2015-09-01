// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_read_frames.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : This file contains sequence items
*
* Classes :	1. axi_read_base_frame
*			2. axi_read_single_frame
*			3. axi_read_single_addr
*			4. axi_read_burst_frame
*			5. axi_read_whole_burst
*			6. ready_randomization // TODO : MOVE!!!
**/
// -----------------------------------------------------------------------------

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

	rand bit [DATA_WIDTH-1 : 0]	data;
	rand response_enum			resp;
	bit							last;
	// user

	// control
	rand last_enum				last_mode;	// rlast signal generated correcty or not
	err_enum					err;	// used for early termination and bad last bit for last frame in burst
	rand bit 					read_enable;	// read from memory or return random data

	// control bit for default value of rresp signal
	rand bit default_resp;	// if set use default value for resp (OKAY)

	constraint default_last_bit {last_mode dist {GOOD_LAST_BIT := 90, BAD_LAST_BIT := 10};}
	//constraint default_last_bit {last_mode == GOOD_LAST_BIT;}	// TODO : put back to dist

	constraint default_read_enable {read_enable dist {1 := 90, 0 := 10};}
	//constraint default_read_enable {read_enable == 1;}

	constraint default_resp_constraint {
		if (default_resp) {
			resp == OKAY;
		}
	}

	// UVM utility macros
	`uvm_object_utils_begin(axi_read_single_frame)
		`uvm_field_int(data, UVM_DEFAULT)
		`uvm_field_enum(response_enum, resp, UVM_DEFAULT)
		`uvm_field_int(last, UVM_DEFAULT)
		`uvm_field_enum(last_enum, last_mode, UVM_DEFAULT)
		`uvm_field_enum(err_enum, err, UVM_DEFAULT)
		`uvm_field_int(read_enable, UVM_DEFAULT)
		`uvm_field_int(default_resp, UVM_DEFAULT)
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
// CLASS: axi_read_single_addr
//
//------------------------------------------------------------------------------
class axi_read_single_addr extends axi_read_single_frame;

	rand bit [DATA_WIDTH/8 - 1 : 0] upper_byte_lane;	// the byte lane of the hightest addressed byte of a transfer
	rand bit [DATA_WIDTH/8 - 1 : 0] lower_byte_lane;	// the byte lane of the lowest addressed byte of a transfer
	rand bit [ADDR_WIDTH-1 : 0] addr;	// the address

	// control bit to enable use of wrong byte lanes
	rand bit correct_lane;

	constraint default_correct_lane {correct_lane dist {1 := 90, 0 := 10};}
	//constraint default_correct_lane {correct_lane == 0;}	// TODO : for testing

	constraint lane_constraint {upper_byte_lane >= lower_byte_lane;}

	`uvm_object_utils_begin(axi_read_single_addr)
		`uvm_field_int(upper_byte_lane, UVM_DEFAULT)
		`uvm_field_int(lower_byte_lane, UVM_DEFAULT)
		`uvm_field_int(addr, UVM_DEFAULT)
		`uvm_field_int(correct_lane, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "axi_read_single_addr");
		super.new(name);
	endfunction

endclass : axi_read_single_addr

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

	// control signal - completly random burst or burst following protocol
	rand bit valid_burst;

	// control for default signals - if set, use default value
	rand bit default_id;
	rand bit default_region;
	rand bit default_len;
	rand bit default_size;
	rand bit default_burst_type;
	rand bit default_lock;
	rand bit default_cache;
	rand bit default_qos;

	constraint default_id_constraint {
		if (default_id) {
			id == {ID_WIDTH {1'b0}};
		}
	}
	constraint default_region_constraint {
		if (default_region) {
			region == 4'h0;
		}
	}
	constraint default_len_constraint {
		if (default_len) {
			len == 0;
		}
	}
	constraint default_size_constraint {
		if (default_size) {
			size == BYTE_8;	// TODO : FIX
		}
	}
	constraint default_burst_type_constraint {
		if (default_burst_type) {
			burst_type == INCR;
		}
	}
	constraint default_lock_constraint {
		if (default_lock) {
			lock == NORMAL;
		}
	}
	constraint default_cache_constraint {
		if (default_cache) {
			cache == 4'h0;
		}
	}
	constraint default_qos_constraint {
		if (default_qos) {
			qos == 4'h0;
		}
	}

	constraint delay_constraint {delay < 5;}

	constraint valid_burst_constraint {
		if (valid_burst) {
			// burst length for the INCR type can be 1 - 256, for others 1 - 16
			// for a wrapping burst, length must be 2, 4, 8 or 16
			if (burst_type == FIXED) {
				len < 16;
			}
			else if (burst_type == WRAP) {
				len inside {1, 3, 7, 15};
			}

			// constrain number of bytes in a transfer
			size <= $clog2(DATA_WIDTH / 8);

			// for a wrapping burst the start address must be aligned to the size of each transfer
			// also for exclusive access, address must be aligned
			if (addr == ((int'(addr/(2**size)))*(2**size))) {
				burst_type inside {FIXED, INCR, WRAP};
				lock inside {NORMAL, EXCLUSIVE};
			}
			else {	// address not aligned
				burst_type inside {FIXED, INCR};
				lock == NORMAL;
			}
			// never use Reserved

			// for an exclusive access - the number of bytes must be a power of 2, max 128 bytes
			if (((2**size) * len) inside {1, 3, 7, 15, 31, 63, 127}) {
				lock inside {NORMAL, EXCLUSIVE};
			}
			else {
				lock == NORMAL;
			}
			if(lock == EXCLUSIVE) {
				len < 16;
			}
		}
	}

	constraint valid_burst_order_constraint {
		solve burst_type before len;
		solve addr before burst_type;
		solve size before burst_type;
		solve addr before lock;
		solve size before lock;
	}

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
		`uvm_field_int(valid_burst, UVM_DEFAULT)
		`uvm_field_int(default_id, UVM_DEFAULT)
		`uvm_field_int(default_region, UVM_DEFAULT)
		`uvm_field_int(default_len, UVM_DEFAULT)
		`uvm_field_int(default_size, UVM_DEFAULT)
		`uvm_field_int(default_burst_type, UVM_DEFAULT)
		`uvm_field_int(default_lock, UVM_DEFAULT)
		`uvm_field_int(default_cache, UVM_DEFAULT)
		`uvm_field_int(default_qos, UVM_DEFAULT)
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

	axi_read_single_addr single_frames[$];

	`uvm_object_utils_begin(axi_read_whole_burst)
		//`uvm_field_queue_int(single_frames, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "axi_read_whole_burst");
		super.new(name);
	endfunction

endclass : axi_read_whole_burst

// TODO : premesti negde drugde
class ready_randomization;

	rand bit ready;

	constraint ready_default{
		ready dist {
			0 := 10,
			1 := 90
		};
	}

	function bit getRandom();
		assert(this.randomize());
		return this.ready;
	endfunction : getRandom

endclass : ready_randomization

`endif