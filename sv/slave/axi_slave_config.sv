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

class axi_slave_config extends uvm_object;


	string name="0";

	rand uvm_active_passive_enum is_active = UVM_ACTIVE;
	bit[ADDR_WIDTH-1 : 0] start_address;
	bit[ADDR_WIDTH-1 : 0] end_address;
	rand lock_enum lock;

	constraint addr_cst {start_address <= end_address; }


	`uvm_object_utils_begin(axi_slave_config)
		`uvm_field_string(name,UVM_DEFAULT)
		`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
		`uvm_field_int(start_address,UVM_DEFAULT)
		`uvm_field_int(end_address,UVM_DEFAULT)
		`uvm_field_enum(lock_enum, lock, UVM_DEFAULT)
	`uvm_object_utils_end

	// new - constructor
	function new(string name = "ig");
		super.new(name);
	endfunction: new

	extern function void setStartAddress(input bit[ADDR_WIDTH-1 : 0] input_start_address);
	extern function void setEndAddress(input bit[ADDR_WIDTH-1 : 0] input_stop_address);
	extern function void getStartAddress(output bit[ADDR_WIDTH-1 : 0] output_start_address);
	extern function void getStartAddress(output bit[ADDR_WIDTH-1 : 0] output_end_address);
	extern function void setActivePasive(input uvm_active_passive_enum imput_enum);
	extern function void getActivePasive(output uvm_active_passive_enum output_enum);
	extern function void setLock(input lock_enum input_enum);
	extern function void getLock(output lock_enum output_enum);


endclass : axi_slave_config

function void setStartAddress(input bit[ADDR_WIDTH-1 : 0] input_start_address);
	this.


class slave_config_factory extends uvm_object;

	rand int number_of_slaves;
	bit[ADDR_WIDTH - 1 : 0] addres_bus_width;





endclass : slave_config_factory;

