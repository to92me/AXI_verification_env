/******************************************************************************
	* DVT CODE TEMPLATE: configuration object
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/
`ifndef AXI_SLAVE_CONFIG_SV
`define AXI_SLAVE_CONFIG_SV
//------------------------------------------------------------------------------
//
// CLASS: axi_slave_config
//
//------------------------------------------------------------------------------



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

	 rand uvm_active_passive_enum is_active = UVM_ACTIVE;
	 bit[ADDR_WIDTH-1 : 0] start_address;
	 bit[ADDR_WIDTH-1 : 0] end_address;
	 rand lock_enum lock;


	`uvm_object_utils_begin(axi_slave_config)
		`uvm_field_string(name, UVM_DEFAULT)
		`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
		`uvm_field_int(start_address, UVM_DEFAULT)
		`uvm_field_int(end_address, UVM_DEFAULT)
		`uvm_field_enum(lock_enum, lock, UVM_DEFAULT)
	`uvm_object_utils_end

	constraint lock_cst{
				lock dist{
						NORMAL:= 5,
						EXCLUSIVE := 5
				};
		}

		constraint active_cst{
			is_active dist{
				UVM_ACTIVE := 9,
				UVM_PASSIVE := 1
			};
		}


	// new - constructor
	function new(string name = "slaveNO");
		super.new(name);
	endfunction: new

	// is the address in the defined range
	function bit check_addr_range(int unsigned addr);
		return (!((addr < start_address) || (addr > end_address)));
	endfunction: check_addr_range

endclass : axi_slave_config

//------------------------------------------------------------------------------
//
//  CLASS slave factory
//
//------------------------------------------------------------------------------

class slave_config_factory extends uvm_object;

	rand int number_of_slaves;
	bit[ADDR_WIDTH - 1 : 0] address_points[];
	axi_slave_config slave;

	`uvm_object_utils_begin(slave_config_factory)
	 `uvm_field_int(number_of_slaves, UVM_DEFAULT)
	 `uvm_field_array_int(address_points, UVM_ALL_ON)
	 `uvm_field_object(slave, UVM_DEFAULT)
 `uvm_object_utils_end

	constraint number_of_slaves_csr{
		address_points.size() inside{[5:20]};
	}

	//constraint even_nuber_of_slaves_scs{
	//	address_points.size() % 2 = 0;
	//}

 	function new(string name = "slaveFactory");
		super.new(name);
 	endfunction: new

 	extern function void createSlaves(ref axi_slave_config slave_list[$] , input int numberOfSlaves);



endclass : slave_config_factory


	function void slave_config_factory::createSlaves(ref axi_slave_config slave_list[$], input int numberOfSlaves);
		 address_points.sort();
		/*if(address_points.size() % 2 != 0)
			address_points.delete[address_points.size()];*/

	  for ( int i = 0; i < address_points.size(); i+=2)
		  begin
			  slave = axi_slave_config::type_id::create("slave");
			  slave.start_address = address_points[i];
			  slave.end_address = address_points[i+1];
			  slave_list.push_front(slave);

		  end


	endfunction : createSlaves

//------------------------------------------------------------------------------
//
// CLASS slave_unig_memory_space
// this class provides one unigue slave config that fits constraints ( maximal
// minimal and unique address space)
//
//------------------------------------------------------------------------------



`endif