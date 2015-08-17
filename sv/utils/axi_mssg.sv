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


`endif

