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

class axi_master_write_scheduler extends uvm_object;

	axi_master_write_scheduler_packages burst_queue[$];
	axi_master_write_scheduler_packages single_burst;
	axi_master_write_scheduler_packages next_frame_for_sending;

	rand axi_data rand_data;
	virtual interface axi_if vif;

	extern function void addBurst(input axi_frame);
	extern function void buld();
	extern function axi_data getNexPackageForDriveingVif();
	extern function axi_


endclass : axi_master_write_scheduler
