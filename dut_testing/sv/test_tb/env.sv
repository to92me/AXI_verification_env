`ifndef AXI_DUT_REGISTER_MODEL_ENV_SVH_
`define AXI_DUT_REGISTER_MODEL_ENV_SVH_


typedef uvm_reg_predictor#(dut_frame) dut_register_model_predictor;
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_env
//
//------------------------------------------------------------------------------

class dut_register_model_env extends uvm_env;


	protected virtual interface axi_if 			vif0;
	protected virtual interface dut_helper_vif	vif1;

	bit 								checks_enable 			= 1;
	bit 								coverage_enable 		= 1;

	dut_register_model_config			config_obj;
	axi_write_wrapper_agent 			wrapper_write_agent;
	axi_read_wrapper_agent				wrapper_read_agent;
	axi_master_write_agent				write_agent;
	axi_master_read_agent				read_agent;

	axi_write_configuration_wrapper		configuration_wrapper;
	axi_write_conf						uvc_configuration;

	dut_register_model_lower_sequencer	low_sequencer;
	dut_register_model_top_sequencer	top_sequencer;
	dut_register_model_top_monitor		monitor;

	dut_register_model_predictor		predictor;
	dut_register_model_adapter			adapter;
	dut_register_block					register_block;
	uvm_reg_map 						register_map;
	dut_reference_model					reference_model;




	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(dut_register_model_env)
		 `uvm_field_int(checks_enable, UVM_DEFAULT | UVM_UNSIGNED)
		 `uvm_field_int(coverage_enable, UVM_DEFAULT | UVM_UNSIGNED)
		 `uvm_field_object(config_obj, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern function void start_of_simulation_phase(uvm_phase phase);
	extern function void update_config(axi_config config_obj);
	extern task run_phase(uvm_phase phase);
	extern task update_vif_enables();


endclass : dut_register_model_env

function void dut_register_model_env::build_phase(uvm_phase phase);
	super.build_phase(phase);

		if(config_obj == null) //begin
			if (!uvm_config_db#(dut_register_model_config)::get(this, "", "axi_config", config_obj)) begin
				`uvm_info("NOCONFIG", "Using default_axi_config", UVM_MEDIUM)
				$cast(config_obj, factory.create_object_by_name("dut_register_model_config","config_obj"));
			end

		write_agent 			= axi_master_write_agent::type_id::create(	"MasterWriteAgent",		this);
		wrapper_write_agent		= axi_write_wrapper_agent::type_id::create(	"AxiWriteWrapperAgent",	this);
		read_agent 				= axi_master_read_agent::type_id::create(	"MasterReadAgent", 		this);
		wrapper_read_agent		= axi_read_wrapper_agent::type_id::create(	"AxiReadWrapperAgent", 	this);

		wrapper_write_agent.setAxiWriteAgent(write_agent);
		wrapper_read_agent.setAxiReadAgent(read_agent);

		predictor				= dut_register_model_predictor::type_id::create("DutRegisterModelPredictor",this);
		adapter					= dut_register_model_adapter::type_id::create(	"DutRegisterModelAdapter", 	this);

		register_map 			= register_block.get_default_map();
		reference_model			= dut_reference_model::type_id::create(			"DutRegisterModelBlock", 	this);
		reference_model.dut_register_model = register_block;

		low_sequencer			= dut_register_model_lower_sequencer::type_id::create(	"DutRegisterModelLowSequencer", this);
		top_sequencer			= dut_register_model_top_sequencer::type_id::create(	"DutRegisterModelTopSequencer", this);

		monitor					= dut_register_model_top_monitor::type_id::create("DutRegisterModelMonitor", this);


endfunction : build_phase


function void dut_register_model_env::connect_phase(input uvm_phase phase);
		super.connect_phase(phase);

		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif0))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});

		low_sequencer.setReadSequncer(wrapper_read_agent.getTopSequencer());
		low_sequencer.setWriteSequencer(wrapper_write_agent.getTopSequencer());

		wrapper_write_agent.wrapper_monitor.wrapper_port.connect(monitor.write_monitor_import);
		wrapper_read_agent.wrapper_monitor.wrapper_port.connect(monitor.read_monitor_import);

		predictor.map 		= register_map;
		predictor.adapter	= adapter;
		monitor.top_monitor_port.connect(predictor.bus_in);

		register_map.set_sequencer(top_sequencer, adapter);

//		write_agent.driver.seq_item_port.connect(wrapper_write_agent.wrapper_low_sequencer.seq_item_export);
//		read_agent.driver.seq_item_port.connect(wrapper_read_agent.wrapper_low_sequencer.seq_item_export);

		low_sequencer.upper_seq_item_port.connect(top_sequencer.seq_item_export);

		write_agent.monitor.burst_port.connect(reference_model.write_monitor_import);

	endfunction


	// UVM start_of_simulation_phase
	function void dut_register_model_env::start_of_simulation_phase(uvm_phase phase);
		set_report_id_action_hier("CFGOVR", UVM_DISPLAY);
		set_report_id_action_hier("CFGSET", UVM_DISPLAY);
		check_config_usage();
	endfunction : start_of_simulation_phase

// update_config() method
function void dut_register_model_env::update_config(axi_config config_obj);

endfunction : update_config

// update_vif_enables
task dut_register_model_env::update_vif_enables();
	vif0.has_checks <= checks_enable;
	vif0.has_coverage <= coverage_enable;
	forever begin
		@(checks_enable || coverage_enable);
    	vif0.has_checks <= checks_enable;
    	vif0.has_coverage <= coverage_enable;
	end
endtask : update_vif_enables

//UVM run_phase()
task dut_register_model_env::run_phase(uvm_phase phase);
  fork
    update_vif_enables();
	reference_model.main();
  join
endtask : run_phase


`endif
