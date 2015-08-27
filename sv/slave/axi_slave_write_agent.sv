`ifndef AXI_SLAVE_WRITE_AGENT
`define AXI_SLAVE_WRITE_AGENT

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_agent
//
//------------------------------------------------------------------------------

class axi_slave_write_agent extends uvm_agent;

//	string 							agent_name = "AxiSlaveWriteAgent";
	axi_slave_config 				config_obj;
	true_false_enum					tesiting_one_slave = TRUE;

	axi_slave_write_driver 			driver;
	axi_slave_write_sequencer 		sequencer;
//	uvc_company_uvc_name_monitor monitor; // TODO


`uvm_component_utils_begin(axi_slave_write_agent)
	`uvm_field_object(config_obj, UVM_DEFAULT)
	`uvm_field_object(driver, UVM_DEFAULT)
	`uvm_field_object(sequencer, UVM_DEFAULT)
`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
//		this.agent_name = name;
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
//		monitor = axi_slave_write_monitor::type_id::create("monitor", this);

		if(!uvm_config_db#(axi_slave_config)::get(this,"","axi_slave_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"}) // FIXME slave config fix

		if(config_obj.is_active == UVM_ACTIVE)
			begin
				sequencer = axi_slave_write_sequencer::type_id::create("sequencer", this);
				driver = axi_slave_write_driver::type_id::create("driver", this);
				driver.setSlaveConfig(config_obj);
			end
	endfunction : build_phase

	// connect_phase
	function void connect_phase(uvm_phase phase);
//		if(config_obj.is_active == UVM_ACTIVE) begin
//			driver.seq_item_port.connect(sequencer.seq_item_export);
//		end
	endfunction : connect_phase

	extern function void  updateSlaveConfig(axi_slave_config slave_config);


endclass : axi_slave_write_agent


function void axi_slave_write_agent::updateSlaveConfig(input axi_slave_config slave_config);

endfunction


`endif
