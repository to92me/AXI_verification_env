`ifndef AXI_SLAVE_WRITE_ADDRESS_COLLECTOR
`define AXI_SLAVE_WRITE_ADDRESS_COLLECTOR

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_write_address_collector
//
//------------------------------------------------------------------------------

class axi_slave_write_address_collector extends axi_slave_write_base_collector;

	`uvm_component_utils(axi_slave_write_address_collector)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern task sendData();
	extern task checkWaliTransaction(ref true_false_enum valid_transaction);

endclass : axi_slave_write_address_collector


task axi_slave_write_address_collector::checkWaliTransaction(ref true_false_enum valid_transaction);
   if(vif.awvalid == 1 && vif.awready == 1)
	   valid_transaction = TRUE;
   else
	   valid_transaction = FALSE;
endtask


task axi_slave_write_address_collector::sendData();
	axi_write_address_collector_mssg mssg;
	mssg = new();

	mssg.setAddr(vif.awaddr);
	mssg.setBurst_type(vif.awburst);
	mssg.setCache(vif.awcache);
	mssg.setId(vif.awid);
	mssg.setLen(vif.awlen);
	mssg.setLock(vif.awlock);
	mssg.setProt(vif.awprot);
	mssg.setQos(vif.awqos);
	mssg.setRegion(vif.awregion);
	mssg.setSize(vif.awsize);

	main_monitor.pushAddressItem(mssg);

endtask



`endif