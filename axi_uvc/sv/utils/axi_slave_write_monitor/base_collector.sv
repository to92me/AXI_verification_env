`ifndef AXI_SLAVE_BASE_COLLECOTOR_SVH
`define AXI_SLAVE_BASE_COLLECOTOR_SVH


//------------------------------------------------------------------------------
//
// CLASS: axi_slave_write_base_collector
//
//------------------------------------------------------------------------------



class axi_slave_write_base_collector extends uvm_component;

	virtual interface axi_if				vif;
	axi_slave_write_main_monitor   	  		main_monitor;



	`uvm_component_utils(axi_slave_write_base_collector)


	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_name(),$sformatf("Building Axi Write Slave base driver "), UVM_LOW);

		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})

	endfunction : build_phase

	extern task main();
	extern virtual task checkWaliTransaction(ref true_false_enum valid_transaction);
	extern virtual task sendData();
	extern function void setMainMonitorInstance(input axi_slave_write_main_monitor driver_instance);

endclass : axi_slave_write_base_collector

function void axi_slave_write_base_collector::setMainMonitorInstance(input axi_slave_write_main_monitor driver_instance);
	this.main_monitor = driver_instance;
endfunction


task axi_slave_write_base_collector::main();
   	axi_write_base_collector_state_enum state;
	true_false_enum 					valid_transaction;

	forever begin
		case(state)
			WAIT_WALID_TRANSACTION:
			begin
				@(posedge vif.sig_clock)
				this.checkWaliTransaction(valid_transaction);
				if(valid_transaction == TRUE)
					state = SEND_COLLECTED_DATA;
				else
					state = WAIT_WALID_TRANSACTION;
			end

			SEND_COLLECTED_DATA:
			begin
				this.sendData();
				state = WAIT_WALID_TRANSACTION;
			end
		endcase
	end
endtask



task axi_slave_write_base_collector::checkWaliTransaction(ref true_false_enum valid_transaction);
    $display("AXI slave WRITE MONITOR: BASE COLLECTOR: checkWaliTransaction() NOT IMPLEMENTED !!! ");
	valid_transaction = FALSE;
endtask

task axi_slave_write_base_collector::sendData();
    $display("AXI slave WRITE MONITOR: BASE COLLECTOR: sendData() NOT IMPLEMENTED !!! ");
endtask



`endif