`ifndef AXI_SLAVE_WRITE_DATA_COLLECTOR_SVH
`define AXI_SLAVE_WRITE_DATA_COLLECTOR_SVH

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_write_data_collector
//
//------------------------------------------------------------------------------

class axi_slave_write_data_collector extends axi_slave_write_base_collector;


	`uvm_component_utils(axi_slave_write_data_collector)

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

endclass : axi_slave_write_data_collector


task axi_slave_write_data_collector::checkWaliTransaction(ref true_false_enum valid_transaction);
    if(vif.wvalid == 1 && vif.wready == 1)
	   valid_transaction = TRUE;
   else
	   valid_transaction = FALSE;
endtask

task axi_slave_write_data_collector::sendData();
	axi_write_data_collector_mssg mssg;
	mssg = new();

	mssg.setData(vif.wdata);
	mssg.setId(vif.wid);
	mssg.setLast(vif.wlast);
	mssg.setStrobe(vif.wstrb);
	mssg.setUser(vif.wuser);

	main_monitor.pushDataItem(mssg);

endtask

`endif