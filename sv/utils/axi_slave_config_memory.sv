`ifndef AXI_SLAVE_CONFIG_MEMORY_SVH
`define AXI_SLAVE_CONFIG_MEMORY_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------
import uvm_pkg::*;
	`include "uvm_macros.svh"

// this class is strcut but because uvm can handle struct it is class with two fields and no methodes
class axi_slave_config_memory_field;   // FIXME proveriti da li mozda moze da radi da je component ? da li ce onda moci dinamicki da
									   // se dodaje posto je pravilo probleme kada sam radio new izvan build


	bit [DATA_WIDTH-1 : 0] 			data;
	bit [ADDR_WIDTH-1 : 0]			addr;

/*
`uvm_component_utils_begin(axi_slave_config_memory_field)
	 `uvm_field_int(data, UVM_DEFAULT)
	 `uvm_field_int(addr, UVM_DEFAULT)
`uvm_component_utils_end
*/
/*
function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase
*/
endclass



class axi_slave_config_memory extends uvm_component;
	axi_slave_config_memory_field 		memory_queue[$];
	axi_slave_config_memory_field		memory_field;
	axi_slave_memory_response			rsp;
	semaphore 							sem;


	extern task read(input bit [ADDR_WIDTH-1 : 0] read_addr, output axi_slave_memory_response read_rsp);
	extern task write( bit [ADDR_WIDTH-1 : 0] write_addr, input bit [DATA_WIDTH-1 : 0] write_data);



`uvm_component_utils_begin(axi_slave_config_memory)
//	 `uvm_field_queue_object(memory_queue, UVM_DEFAULT)
//	 `uvm_field_object(memory_field, UVM_DEFAULT)
 `uvm_component_utils_end


	function new (string name, uvm_component parent);
		super.new(name, parent);
		sem = new(1);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

endclass : axi_slave_config_memory


task axi_slave_config_memory::read(input bit [ADDR_WIDTH-1 : 0] read_addr, output axi_slave_memory_response read_rsp);
	int i;
	rsp = new();
	rsp.setValid(FALSE);

	sem.get(1);
	foreach(memory_queue[i])
		begin
			if(read_addr == memory_queue[i].addr)
				begin
					rsp.setData(memory_queue[i].data);
					rsp.setValid(TRUE);
					rsp.setAddr(memory_queue[i].addr);
				end
		end
	sem.put(1);
	if (rsp.getValid() == FALSE)
		`uvm_info(get_name(),$sformatf("reding from empyt memory space, address : %d ", read_addr), UVM_LOW)

endtask;

task axi_slave_config_memory::write(input bit[ADDR_WIDTH-1:0] write_addr, input bit[DATA_WIDTH-1:0] write_data);
    int i;
	true_false_enum written = FALSE;

	sem.get(1);
	foreach(memory_queue[i])
		begin
			if( write_addr == memory_queue[i].addr)   // if there is already data on this address rewrite it
				begin
					memory_queue[i].data = write_data;
					written = TRUE;
				end
		end
	sem.put(1);


	if (written == FALSE)							// if not create field and fill it
		begin
			memory_field = new();
			memory_field.addr = write_addr;
			memory_field.data = write_data;
			sem.get(1);
			memory_queue.push_back(memory_field);
			sem.put(1);
		end

endtask



`endif
