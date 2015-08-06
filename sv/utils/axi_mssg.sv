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

	bit[ADDR_WIDTH-1 : 0] data;
	axi_mssg_enum state;

endclass : axi_mssg


// axi data represents one data and his delay that contains axi_scheduler_package
class axi_data ;

	bit[ADDR_WIDTH-1 : 0] data;
	bit[2:0] delay;
	bit [ID_WIDTH-1 : 0] id;

endclass : axi_data