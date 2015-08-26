/******************************************************************************
	* DVT CODE TEMPLATE: component
	* Created by andrea on Aug 24, 2015
	* uvc_company = axi, uvc_name = address_calc
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_address_calc
//
//------------------------------------------------------------------------------

class axi_address_calc extends uvm_sequence_item;

	int upper_byte_lane;	// the byte lane of the hightest addressed byte of a transfer
	int lower_byte_lane;	// the byte lane of the lowest addressed byte of a transfer
	bit [ADDR_WIDTH-1 : 0] addr;	// the address

	`uvm_object_utils_begin(axi_address_calc)
		`uvm_field_int(upper_byte_lane, UVM_DEFAULT)
		`uvm_field_int(lower_byte_lane, UVM_DEFAULT)
		`uvm_field_int(addr, UVM_DEFAULT)
	`uvm_object_utils_end

	// new - constructor
	function new (string name="axi_address_calc");
		super.new(name);
	endfunction : new

endclass : axi_address_calc

//------------------------------------------------------------------------------
//
// CLASS: axi_address_queue
//
//------------------------------------------------------------------------------

class axi_address_queue;

	axi_address_calc addr_queue[$];

	// new - constructor
	function new (string name = "axi_address_queue", uvm_component parent = null);
		//super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		//super.build_phase(phase);
	endfunction : build_phase

	extern virtual function void calc_addr(bit[ADDR_WIDTH-1:0] start_addr, burst_size_enum size, bit[7:0] burst_len, burst_type_enum mode);
	extern virtual function axi_address_calc pop_front();

endclass : axi_address_queue

// calculate all addreses used by the given burst
// start_addr : start address issued by the master
// burst_len : total number of data transfers within a burst
function void axi_address_queue::calc_addr(bit[ADDR_WIDTH-1:0] start_addr, burst_size_enum size, bit[7:0] burst_len, burst_type_enum mode);

	axi_address_calc addr_frame;

	bit [ADDR_WIDTH-1 : 0] addr, aligned_addr;
	int dtsize, num_bytes, data_bus_bytes;
	int lower_wrap_boundary, upper_wrap_boundary;	// lowest and highest address within a wrapping burst
	bit aligned;

	addr_frame = axi_address_calc::type_id::create("addr_frame");

	num_bytes = 2**size;	// the max number of bytes in each data transfer
	data_bus_bytes = DATA_WIDTH / 8;	// the number of byte lanes in the data bus

	assert(mode inside {FIXED, INCR, WRAP});	// check that Reserved is not used

	addr = start_addr;	// variable for current address = start address issued by master
	aligned_addr = ($floor(addr/num_bytes)*num_bytes);	// the aligned version of the start address
	aligned = (aligned_addr == addr);	// check whether addr is aligned to num_bytes

	dtsize = num_bytes * (burst_len+1);	// max total data transaction size

	if (mode == WRAP) begin
		lower_wrap_boundary = ($floor(addr/dtsize) * dtsize);
		// address must be aligned for a wrapping burst
		upper_wrap_boundary = lower_wrap_boundary + dtsize;
	end

	for(int i = 0; i < burst_len; i++) begin
		addr_frame.lower_byte_lane = addr - ($floor(addr/data_bus_bytes)) * data_bus_bytes;

		if (aligned) begin
			addr_frame.upper_byte_lane = addr_frame.lower_byte_lane + num_bytes - 1;
		end
		else begin
			addr_frame.upper_byte_lane = aligned_addr + num_bytes - 1 - ($floor(addr/data_bus_bytes)) * data_bus_bytes;
		end

		addr_frame.addr = addr;

		// put address in queue
		addr_queue.push_back(addr_frame);

		// increment address if necessary
		if (mode != FIXED) begin
			if (aligned) begin
				addr = addr + num_bytes;
				if (mode == WRAP)
					// WRAP mode is always aligned
					if (addr >= upper_wrap_boundary)
						addr = lower_wrap_boundary;
			end
			else begin
				addr = addr + num_bytes;
				aligned = 1;	// all transfers after the first are aligned
			end
		end
	end
endfunction : calc_addr

function axi_address_calc axi_address_queue::pop_front();
	return addr_queue.pop_front();
endfunction : pop_front