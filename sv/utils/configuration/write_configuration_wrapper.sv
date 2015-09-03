

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_write_config_field;
	string 			scope_name;
	string 			option_name;
	int 			option_value;

	// Get option_name
	function string getOption_name();
		return option_name;
	endfunction

	// Set option_name
	function void setOption_name(string option_name);
		this.option_name = option_name;
	endfunction

	function string getScope_name();
		return this.scope_name;
	endfunction

	function void setScope_name(input string scope_name);
		this.scope_name = scope_name;
	endfunction

	// Get value
	function int getValue();
		return option_value;
	endfunction

	// Set value
	function void setValue(int option_value);
		this.option_value = option_value;
	endfunction

endclass

//------------------------------------------------------------------------------
//
// CLASS: axi_write_user_config_base
//
//-----------------------------------------------------------------------------


class axi_write_user_config_base extends uvm_component;
	axi_write_config_field				conf_queue[$];

	`uvm_component_utils(axi_write_user_config_base)


	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern virtual function void setConfigurations();
 	extern function void registerConfiguration();
	extern function int checkTrueFalseEnum(input int int_boolean);
	function axi_write_config_field getConfQueue();
		return conf_queue;
	endfunction

endclass

function axi_write_user_config_base::registerConfiguration(input string scope_name, string option_name, int option_value);
	axi_write_config_field  conf;
	conf = new();

	conf.setScope_name(scope_name);
	conf.setOption_name(option_name);
	conf.setValue(option_value);

	conf_queue.push_back(conf);
endfunction


function axi_write_user_config_base::checkTrueFalseEnum(input int int_boolean);
   if(int_boolean < 2 && int_boolean > -1)
	   return int_boolean;
   else
	   		`uvm_warning("Conifiguration Wrapper","Incorrect boolean option")
	   return -1;

endfunction

function axi_write_user_config_base::setConfigurations();
	$display("OVERIDE THIS FOR CONFIGURATION");
endfunction


//------------------------------------------------------------------------------
//
// CLASS: axi_write_user_config_base
//
//-----------------------------------------------------------------------------


class axi_write_user_conf_package extends uvm_component;
	axi_write_user_config_base			user_conf;
	int 								conf_id;
	true_false_enum						valid_configuration;

	// Get conf_id
	function int getConf_id();
		return conf_id;
	endfunction

	// Set conf_id
	function void setConf_id(int conf_id);
		this.conf_id = conf_id;
	endfunction

	// Get user_conf
	function axi_write_user_config_base getUser_conf();
		return user_conf;
	endfunction

	// Set user_conf
	function void setUser_conf(axi_write_user_config_base user_conf);
		this.user_conf = user_conf;
	endfunction

	// Get valid_configuration
	function true_false_enum getValid_configuration();
		return valid_configuration;
	endfunction

	// Set valid_configuration
	function void setValid_configuration(true_false_enum valid_configuration);
		this.valid_configuration = valid_configuration;
	endfunction

endclass


//------------------------------------------------------------------------------
//
// CLASS: axi_write_configuration_warapper
//
//------------------------------------------------------------------------------



class axi_write_configuration_warapper extends uvm_component;

	uvc_axi_write_conf							conf;
	axi_write_configuration_register			register_user_conf;
	static 	axi_write_configuration_warapper	wraper_instance;
	axi_write_user_conf_package					user_confs_queue[$];

	axi_write_user_conf_package					master_data_conf[$];
	axi_write_user_conf_package					master_addr_conf[$];
	axi_write_user_conf_package					master_resp_conf[$];
	axi_write_user_conf_package					slave_data_conf[$];
	axi_write_user_conf_package					slave_addr_conf[$];
	axi_write_user_conf_package					slave_resp_conf[$];
	axi_write_user_conf_package					global_conf[$];
	axi_write_user_conf_package					correct_value_conf[$];

	string 										master_data[$];
	string 										master_addr[$];
	string 										master_resp[$];
	string 										slave_data[$];
	string 										slave_resp[$];
	string 										slave_addr[$];
	string 										globalc[$];
	string										correct_value[$];



	`uvm_component_utils(axi_write_configuration_warapper)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern function void init();
	extern function uvc_axi_write_conf generateConfigurationObject();
	extern static function axi_write_configuration_warapper getWraperInstance(input uvm_object parent);
	extern function int registerConfiguration(input axi_write_user_config_base configuration);
//	extern function void arrangeConfigurationQueue();
//	extern function void fillBusWritingData(string queue);

endclass : axi_write_configuration_warapper

function axi_write_configuration_warapper::generateConfigurationObject();
 // TODO
endfunction


function axi_write_configuration_warapper axi_write_configuration_warapper::getWraperInstance(input uvm_object parent);
	if(wraper_instance == null)
		begin
			$display("AxiWriteConfigurationWrapper is created ");
			wraper_instance = new("AxiWriteConfigurationWrapper", parent);
		end
	return wraper_instance;
endfunction

function int axi_write_configuration_warapper::registerConfiguration(input axi_write_user_config_base configuration_instance, true_false_enum valid_conf);
 	axi_write_user_conf_package conf;

	conf.setConf_id(user_confs_queue.size());
	conf.setValid_configuration(valid_conf);
	conf.setUser_conf(configuration_instance);

	user_confs_queue.push_front(conf);
	return conf.getConf_id();
endfunction


function void  axi_write_configuration_warapper::init();
endfunction







