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

class axi_mssg ;

	bit[ADDR_WIDTH-1 : 0] data;
	axi_mssg_enum state;

endclass : axi_mssg


class axi_data ;

	bit[ADDR_WIDTH-1 : 0] data;
	bit[2:0] delay;

endclass : axi_data