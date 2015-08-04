/******************************************************************************
	* DVT CODE TEMPLATE: interface
	* Created by root on Aug 2, 2015
	* ovc_company = ovc_company, ovc_name = ovc_name ovc_if = ovc_if
	* interface arguments = interface_args
*******************************************************************************/

//-------------------------------------------------------------------------
//
// INTERFACE: ovc_company_ovc_name_ovc_if
//
//-------------------------------------------------------------------------


interface ovc_company_ovc_name_ovc_if (interface_args);




	// WRITE SIGNALS

	//address write signals
	logic [ADDR_WIDTH-1 : 0]	awaddr;
	logic [7:0]					awlen;
	logic [2:0]					awburst;
	logic [1:0]					awlock;
	logic [3:0]					awcache;
	logic [2:0] 				awprot;
	logic [4:0]					awqos;
	// awregion
	// awuser
    logic 						awvalid;
	logic 						awready;

	//data write signals
	logic



endinterface : ovc_company_ovc_name_ovc_if
