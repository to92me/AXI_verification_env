/******************************************************************************
	* DVT CODE TEMPLATE: component
	* Created by root on Aug 5, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

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

// this class is used to check if it is unique ID
// field counter had been deleted because ordering is set from queue order number;
class unique_id_struct;
	id_type_enum id_status = UNIQUE_ID; // this is defaulh and if needs to be set
	bit [ID_WIDTH-1 : 0] ID;
endclass: unique_id_struct

class axi_burst_package_status;


endclass: axi_burst_package_status

// axi data epresentsone data and his delay that contains axi_scheduler_package