`ifndef AXI_MASTER_WRITE_MSSG_SVH
`define AXI_MASTER_WRITE_MSSG_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

// axi mssg is for sending data to scheduler if package is ready or not

class axi_mssg ;

	axi_single_frame frame;
	axi_mssg_enum state;

endclass : axi_mssg


class unique_id_struct;
	id_type_enum id_status = UNIQUE_ID;
	bit [ID_WIDTH-1 : 0] ID;
endclass: unique_id_struct

class axi_waiting_resp;
	axi_frame  			 frame;
	int 				 counter;
endclass

class axi_slave_response;
	bit [ID_WIDTH-1 : 0]	ID;
	response_enum 			resp;
endclass



class axi_slave_memory_response;


	axi_slave_config_memory_field memory_field;
	true_false_enum valid_data = FALSE;


	extern function 	bit [DATA_WIDTH-1 : 0]  		getData();
	extern function 	bit [ADDR_WIDTH-1 : 0]  		getAddr();
	extern function 	true_false_enum 				getValid();
	extern function 	axi_slave_config_memory_field 	getField();

	extern function void	setData(input bit [DATA_WIDTH-1 : 0] write_data);
	extern function void	setAddr(input bit [ADDR_WIDTH-1 : 0] write_addr);
	extern function void 	setValid(input true_false_enum write_valid);
	extern function void	setField(input axi_slave_config_memory_field write_field);


endclass

function bit [ADDR_WIDTH-1 : 0] axi_slave_memory_response::getAddr();
    return memory_field.addr;
endfunction

function bit [DATA_WIDTH-1 : 0] axi_slave_memory_response::getData();
    return memory_field.data;
endfunction

function axi_slave_config_memory_field axi_slave_memory_response::getField();
    return memory_field;
endfunction

function true_false_enum axi_slave_memory_response::getValid();
    return valid_data;
endfunction

function void axi_slave_memory_response::setAddr(input bit[ADDR_WIDTH-1:0] write_addr);
    this.memory_field.addr = write_addr;
endfunction

function void axi_slave_memory_response::setData(input bit[DATA_WIDTH-1:0] write_data);
    this.memory_field.data = write_data;
endfunction

function void axi_slave_memory_response::setField(input axi_slave_config_memory_field write_field);
    this.memory_field = write_field;
endfunction

function void axi_slave_memory_response::setValid(input true_false_enum write_valid);
	this.valid_data = write_valid;
endfunction

`endif

