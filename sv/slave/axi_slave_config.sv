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

class axi_slave_config extends uvm_object;

	string name="slaveName";
	int slave_ID = 0;

	rand uvm_active_passive_enum is_active = UVM_ACTIVE;
	rand bit[ADDR_WIDTH-1 : 0] start_address;
	rand bit[ADDR_WIDTH-1 : 0] end_address;
	rand lock_enum lock;
	constraint addr_cst {start_address <= end_address; }

	}

	`uvm_object_utils_begin(axi_slave_config)
		`uvm_field_string(name, UVM_DEFAULT)
		`uvm_field_int(slave_ID, UVM_DEFAULT)
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



class slave_config_factory extends uvm_object;

	rand int number_of_slaves;
	bit[ADDR_WIDTH - 1 : 0] address_bus_width;
	bit[ADDR_WIDTH - 1 : 0] max_slave_address_size;
	axi_slave_config slave;

	`uvm_object_utils_begin(slave_config_factory)
	 `uvm_field_int(number_of_slaves, UVM_DEFAULT)
	 `uvm_field_int(address_bus_width, UVM_DEFAULT)
	 `uvm_field_int(max_slave_address_size, UVM_DEFAULT)
	 `uvm_field_object(slave, UVM_DEFAULT)
	`uvm_object_utils_end

 	function new(string name = "slaveFactory");
		super.new(name);
 	endfunction: new

 	extern function void createSlaves(ref axi_slave_config save_list[numberOfSlaves], input int numberOfSlaves );
 	extern function bit[ADDR_WIDTH - 1 : 0] createMaxSlaveAddress(input int numberOfSlaves);


endclass : slave_config_factory;

	function bit[ADDR_WIDTH - 1 : 0] slave_config_factory::createMaxSlaveAddress(input int numberOfSlaves);
	     bit[ADDR_WIDTH - 1 : 0] max , tmp = 0;
		 max = tmp - 1;
		return max / numberOfSlaves;
	endfunction

	function void slave_config_factory::createSlaves(ref axi_slave_config save_list[numberOfSlaves], input int numberOfSlaves);

		bit[ADDR_WIDTH - 1 : 0] maximal_slave_address = createMaxSlaveAddress(numberOfSlaves);
	    for( int i = 0; i <= numberOfSlaves; i++)
		    begin

		    end;

	endfunction

