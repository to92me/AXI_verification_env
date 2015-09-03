`ifndef AXI_SLAVE_CONFIG_SVH
`define AXI_SLAVE_CONFIG_SVH
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


class axi_slave_config_randomize_addres_space extends uvm_object;
	rand bit[ADDR_WIDTH - 1 : 0] 	address_points[];
	int 							number_of_slaves;


	constraint number_of_slaves_csr{
		address_points.size() == number_of_slaves*2;
	}


	function new(string name = "slave config randomize address space");
		super.new(name);
	endfunction: new

endclass


//------------------------------------------------------------------------------
//
//  CLASS AXI_CONFIG
//
//------------------------------------------------------------------------------


class axi_slave_config extends uvm_object;

	string slave_name="slaveName";

	rand uvm_active_passive_enum 		is_active = UVM_ACTIVE;
	bit[ADDR_WIDTH-1 : 0] 				start_address;
	bit[ADDR_WIDTH-1 : 0] 				end_address;
	rand lock_enum 						lock;
	axi_slave_config_memory 			memory;


	`uvm_object_utils_begin(axi_slave_config)
	 `uvm_field_string(slave_name, UVM_DEFAULT)
	 `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
	 `uvm_field_int(start_address, UVM_DEFAULT)
	 `uvm_field_int(end_address, UVM_DEFAULT)
	 `uvm_field_enum(lock_enum, lock, UVM_DEFAULT)
//	 `uvm_field_object(memory, UVM_DEFAULT)
 `uvm_object_utils_end

	constraint lock_cst{
				lock dist{
						NORMAL:= 5,
						EXCLUSIVE := 5
				};
		}

		constraint active_cst{
			is_active dist{
				UVM_ACTIVE := 999999,
				UVM_PASSIVE := 1
			};
		}


	// new - constructor
	function new(string name = "slave_config");
		super.new(name);
		memory = new();
	endfunction: new

	// is the address in the defined range
	function bit check_addr_range(int unsigned addr);
		return (!((addr < start_address) || (addr > end_address)));
	endfunction: check_addr_range

	extern task readMemory(input bit [ADDR_WIDTH-1 : 0] read_addr, output axi_slave_memory_response read_rsp);
	extern task writeMemory( bit [ADDR_WIDTH-1 : 0] write_addr, input bit [DATA_WIDTH-1 : 0] write_data);

endclass : axi_slave_config


task axi_slave_config::readMemory(input bit[ADDR_WIDTH-1:0] read_addr, output axi_slave_memory_response read_rsp);
	if(this.check_addr_range(read_addr))
		begin
			memory.read(read_addr, read_rsp);
		end
	else
		begin
			`uvm_info(get_name(),$sformatf("%s: address boundery error: read_address %d, slave address space : %d ,%d "
				, this.slave_name,read_addr, this.start_address , this.end_address), UVM_FATAL)
		end
endtask

task axi_slave_config::writeMemory(input bit[ADDR_WIDTH-1:0] write_addr, input bit[DATA_WIDTH-1:0] write_data);
    if(this.check_addr_range(write_data))
	    begin
		    memory.write(write_addr, write_data);
	    end
    else
	    begin
		    `uvm_info(get_name(),$sformatf("%s: address boundery error: write_address %d, slave address space : %d ,%d "
			    , this.slave_name,write_addr, this.start_address , this.end_address), UVM_FATAL)
	    end
endtask


//------------------------------------------------------------------------------
//
//  CLASS slave factory
//
//------------------------------------------------------------------------------

class slave_config_factory extends uvm_object;

//	rand int number_of_slaves;
//	rand bit[ADDR_WIDTH - 1 : 0] address_points[];
	axi_slave_config 							slave;
	axi_slave_config_randomize_addres_space 	rand_space;

	`uvm_object_utils_begin(slave_config_factory)
	 `uvm_field_object(slave, UVM_DEFAULT)
	 `uvm_field_object(rand_space, UVM_DEFAULT)
 `uvm_object_utils_end

	//constraint number_of_slaves_csr{
//		address_points.size() == number_of_slaves;
//	}

	//constraint even_nuber_of_slaves_scs{
	//	address_points.size() % 2 = 0;
	//}

 	function new(string name = "slaveFactory");
		super.new(name);
	 	rand_space = new();
 	endfunction: new

 	extern function void createSlaves(ref axi_slave_config slave_list[$], input int numberOfSlaves);

endclass : slave_config_factory


function void slave_config_factory::createSlaves(ref axi_slave_config slave_list[$], input int numberOfSlaves);
		 //number_of_slaves = numberOfSlaves;
		 //address_points.sort();

	rand_space.number_of_slaves = numberOfSlaves;
	assert(rand_space.randomize());
	rand_space.address_points.sort();



	  for ( int i = 0; i < rand_space.address_points.size(); i+=2)
		  begin
			  slave = axi_slave_config::type_id::create($sformatf("slave[%0d]", slave_list.size()));
			  assert (slave.randomize());
			  slave.slave_name = $sformatf("slave[%0d]", slave_list.size());
			  slave.start_address = rand_space.address_points[i];
			  slave.end_address = rand_space.address_points[i+1];
			  slave_list.push_front(slave);
			  slave.print();
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

