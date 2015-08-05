/******************************************************************************
	* DVT CODE TEMPLATE: configuration object
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_config
//
//------------------------------------------------------------------------------
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "sv/axi_types.sv"


enum {
	START_ADDRESS,
	END_ADDRESS
}address_position_enum;

typedef struct{
	bit[ADDR_WIDTH-1 : 0] start_address;
	bit[ADDR_WIDTH-1 : 0] end_addressp;
}slave_address_struct;

//------------------------------------------------------------------------------
//
//  CLASS AXI_CONFIG
//
//------------------------------------------------------------------------------


class axi_slave_config extends uvm_object;

	string name="slaveName";

	 uvm_active_passive_enum is_active = UVM_ACTIVE;
	 bit[ADDR_WIDTH-1 : 0] start_address;
	 bit[ADDR_WIDTH-1 : 0] end_address;
	 lock_enum lock;


	`uvm_object_utils_begin(axi_slave_config)
		`uvm_field_string(name, UVM_DEFAULT)
		`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
		`uvm_field_int(start_address, UVM_DEFAULT)
		`uvm_field_int(end_address, UVM_DEFAULT)
		`uvm_field_enum(lock_enum, lock, UVM_DEFAULT)
	`uvm_object_utils_end


	// new - constructor
	function new(string name = "slaveNO");
		super.new(name);
	endfunction: new

endclass : axi_slave_config

//------------------------------------------------------------------------------
//
//  CLASS slave factory
//
//------------------------------------------------------------------------------

class slave_config_factory extends uvm_object;

	rand int number_of_slaves;
	bit[ADDR_WIDTH - 1 : 0] address_bus_width;
	bit[ADDR_WIDTH - 1 : 0] max_slave_address_size;
	bit[ADDR_WIDTH - 1 : 0] memory_space_queue[$];
	axi_slave_config slave;

	`uvm_object_utils_begin(slave_config_factory)
	 `uvm_field_int(number_of_slaves, UVM_DEFAULT)
	 `uvm_field_int(address_bus_width, UVM_DEFAULT)
	 `uvm_field_int(max_slave_address_size, UVM_DEFAULT)
	 `uvm_field_object(slave, UVM_DEFAULT)
	`uvm_object_utils_end

	slave_unig_memory_space creater;

 	function new(string name = "slaveFactory");
		super.new(name);
 	endfunction: new

 	extern function void createSlaves(ref axi_slave_config save_list[numberOfSlaves], input int numberOfSlaves );
 	extern function bit[ADDR_WIDTH - 1 : 0] createMaxSlaveAddress(input int numberOfSlaves);


endclass : slave_config_factory;

	function bit[ADDR_WIDTH - 1 : 0] slave_config_factory::createMaxSlaveAddress(input int numberOfSlaves);
	     bit[ADDR_WIDTH - 1 : 0] max = 0;
		 max = max - 1;
		return max / numberOfSlaves;
	endfunction

	function void slave_config_factory::createSlaves(ref axi_slave_config save_list[numberOfSlaves], input int numberOfSlaves);
		bit[ADDR_WIDTH - 1 : 0] max = 0;
		bit[ADDR_WIDTH - 1 : 0] maximal_slave_address;
		bit[ADDR_WIDTH - 1 : 0] minimal_slave_address;

		max = max - 1;
		maximal_slave_address = createMaxSlaveAddress(numberOfSlaves);
		minimal_slave_address = 50;

		memory_space_queue.push_front(0);
		memory_space_queue.push_back(max);

	    for( int i = 0; i <= numberOfSlaves; i++)
		    begin
			    slave = axi_slave_config::type_id::create("slave");
			    creater.fill_constraints(memory_space_queue, maximal_slave_address, minimal_slave_address);
			    creater.create_unique_slave(slave);

			    memory_space_queue.push_front(slave.start_address);
			    memory_space_queue.push_back(slave.end_address);

			    memory_space_queue.sort();
		    end;

	endfunction :createSlaves

//------------------------------------------------------------------------------
//
// CLASS slave_unig_memory_space
// this class provides one unigue slave config that fits constraints ( maximal
// minimal and unique address space)
//
//------------------------------------------------------------------------------

	class slave_unig_memory_space extends uvm_object;

		rand bit[ADDR_WIDTH-1 : 0] start_address_create;
		bit[ADDR_WIDTH-1 : 0] end_address_create;
		bit[ADDR_WIDTH-1 : 0] memory_space[$]; // this queue contains all start and stop positions;
		bit[ADDR_WIDTH-1 : 0] minimal_slave_address_space;
		bit[ADDR_WIDTH-1 : 0] maximal_slave_address_space;
		rand bit[ADDR_WIDTH-1 : 0] slave_address_space;
		rand uvm_active_passive_enum is_active_create = UVM_ACTIVE;
		rand lock_enum lock_create;

//		axi_slave_config unique_slave;

		`uvm_object_utils_begin(slave_unig_memory_space)
		  	`uvm_field_int(start_address_create, UVM_DEFAULT)
		  	`uvm_field_int(end_address_create, UVM_DEFAULT)
		  	`uvm_field_queue_int(memory_space, UVM_DEFAULT)
		  	`uvm_field_int(minimal_slave_address_space, UVM_DEFAULT)
		  	`uvm_field_int(maximal_slave_address_space, UVM_DEFAULT)
		  	`uvm_field_int(slave_address_space, UVM_DEFAULT)
//		  	`uvm_field_object(unique_slave, UVM_DEFAULT)
  		`uvm_object_utils_end

		// address space of one slave must be inside maximal and minimal space
		constraint address_size { (start_address_create + slave_address_space) inside {[minimal_slave_address_space : maximal_slave_address_space]}; }
		// start and stop address must be inisde
		constraint address_position {
				for(int i = 0; i < memory_space.size()-1 ; i+2) begin
					start_address_create inside{[memory_space[i] : memory_space[i+1]};
					start_address_create + slave_address_space < memory_space[i+1];
					end;
		}

		constraint lock_cst{
				lock_create dist{
						NORMAL:= 5,
						EXCLUSIVE := 5
				};
		}

		constraint active_cst{
			is_active_create dist{
				UVM_ACTIVE := 9,
				UVM_PASSIVE := 1
			};
		}

		extern function void  create_unique_slave(ref axi_slave_config unique_slave);
		extern function void fill_constraints(ref input_constraint_queue[$], input bit[ADDR_WIDTH-1 : 0] maximal_space, bit[ADDR_WIDTH-1 : 0] mininal_space);

	endclass : slave_unig_memory_space


	function void slave_unig_memory_space::fill_constraints(ref logic input_constraint_queue[$],
		input bit[ADDR_WIDTH-1:0] maximal_space, bit[ADDR_WIDTH-1:0] mininal_space);

	    this.memory_space = input_constraint_queue;
		this.maximal_slave_address_space = maximal_space;
		this.minimal_slave_address_space = mininal_space;

	endfunction


	function void  slave_unig_memory_space::create_unique_slave(ref axi_slave_config unique_slave);

		this.end_address_create = this.start_address_create + slave_address_space;
		unique_slave = axi_slave_config::type_id::create("slave");
	    unique_slave.start_address = this.start_address_create;
		unique_slave.end_address = this.end_address_create;
		unique_slave.is_active = this.slave_address_space;
		unique_slave.lock = this.create;
	    unique_slave.is_active = this.is_active_create;

	endfunction

