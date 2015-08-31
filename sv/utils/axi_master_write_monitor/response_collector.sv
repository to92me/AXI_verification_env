`ifndef AXI_MASTER_WRITE_RESPONSE_COLLECTOR
`define AXI_MASTER_WRITE_RESPONSE_COLLECTOR

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_master_write_response_collector extends axi_master_write_base_collector;


	`uvm_component_utils(axi_master_write_response_collector)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern task sendData();
	extern task checkWaliTransaction(ref true_false_enum valid_transaction);

endclass : axi_master_write_response_collector

task axi_master_write_response_collector::checkWaliTransaction(ref true_false_enum valid_transaction);
    if(vif.bvalid == 1 && vif.bready == 1)
	   valid_transaction = TRUE;
   else
	   valid_transaction = FALSE;
endtask

task axi_master_write_response_collector::sendData();
    axi_write_response_collector_mssg mssg;
	mssg = new();

	mssg.setId(vif.bid);
	mssg.setResp(vif.bresp);

	main_monitor.pushResponseItem(mssg);

endtask

`endif