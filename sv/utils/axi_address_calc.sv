// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_address_calc.sv
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
* Description : calculation of addresses and byte lanes
*
* Classes :	1. axi_address_calc	
*			2. axi_address_queue
*
* Functions :	1. new (string name="axi_address_calc")
*				2. void calc_addr(bit[ADDR_WIDTH-1:0] start_addr,
*					burst_size_enum size, bit[7:0] burst_len,
*					burst_type_enum mode)
*				3. axi_address_calc pop_front()
*
* Tasks :	1. readMemory(input axi_slave_config config_obj,
*				output bit[DATA_WIDTH-1 : 0] return_data)
*			2. writeMemory(input axi_slave_config config_obj,
*				input bit[DATA_WIDTH-1 : 0] input_data)
**/
// -----------------------------------------------------------------------------

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

	extern virtual task readMemory(input axi_slave_config config_obj, output bit[DATA_WIDTH-1 : 0] return_data);
	extern virtual task writeMemory(input axi_slave_config config_obj, input bit[DATA_WIDTH-1 : 0] input_data);

endclass : axi_address_calc

//------------------------------------------------------------------------------
/**
* Task : readMemory
* Purpose : read data from memory
* Inputs : config_obj - contains required memory functions
* Outputs : return_data - data read from memory
* Ref :
**/
//------------------------------------------------------------------------------
task axi_address_calc::readMemory(input axi_slave_config config_obj, output bit[DATA_WIDTH-1 : 0] return_data);
		mem_access read_data;	// union used for reading individual bytes
		axi_slave_memory_response rsp;
		int tmp;

		tmp = this.upper_byte_lane - this.lower_byte_lane + 1;
		for(int i = 0; i < tmp; i++) begin
			config_obj.readMemory(this.addr, rsp);
			if(rsp.getValid() == TRUE) begin
				read_data.lane[this.lower_byte_lane] = rsp.getData();
				this.lower_byte_lane++;
			end
			this.lower_byte_lane++;
			this.addr++;
		end

		return_data = read_data.data;
endtask : readMemory

//------------------------------------------------------------------------------
/**
* Task : writeMemory
* Purpose : write data to memory
* Inputs :	config_obj - contains required memory functions
*			input_data - data to be written
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
task axi_address_calc::writeMemory(input axi_slave_config config_obj, input bit[DATA_WIDTH-1 : 0] input_data);
	mem_access write_data;	// union used for writing individual bytes

	write_data.data = input_data;

	for(int i = 0; i < (this.upper_byte_lane - this.lower_byte_lane + 1); i++) begin
			config_obj.writeMemory(this.addr, write_data.lane[this.lower_byte_lane]);
			lower_byte_lane++;
			this.addr++;
	end
endtask : writeMemory

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

//------------------------------------------------------------------------------
/**
* Function : calc_addr
* Purpose : calculate all addreses and byte lanes used by the given burst
* Parameters :	1. start_addr - start address issued by the master
*				2. size - size of transfer
*				3. burst_len - total number of data transfers within a burst
*				4. mode - burst type (FIXED, INCR or WRAP)
* Return :	void
**/
//------------------------------------------------------------------------------
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

	for(int i = 0; i <= burst_len; i++) begin
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
				addr = aligned_addr + num_bytes;
				aligned = 1;	// all transfers after the first are aligned
			end
		end
	end
endfunction : calc_addr

//------------------------------------------------------------------------------
/**
* Function : calc_addr
* Purpose : return the first axi_addres_calc frame in the queue
* Parameters :
* Return :	axi_address_calc
**/
//------------------------------------------------------------------------------
function axi_address_calc axi_address_queue::pop_front();
	return addr_queue.pop_front();
endfunction : pop_front