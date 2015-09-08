`ifndef AXI_WRITE_CONFIGURATION_BASE_SVH
`define AXI_WRITE_CONFIGURATION_BASE_SVH

	typedef axi_write_config_field 	config_queue[$];
	typedef string 					string_queue[$];
	typedef int						int_queue[$];



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
 	extern function void registerConfiguration(input string scope_name, string option_name, int option_value);
	extern function int checkTrueFalseEnum(input int int_boolean);
	function config_queue getConfQueue();
		return conf_queue;
	endfunction

endclass

function void axi_write_user_config_base::registerConfiguration(input string scope_name, string option_name, int option_value);
	axi_write_config_field  conf;
	$display("new conf registration: \t\t\t %s %s %0d ", scope_name, option_name, option_value);
	conf = new();
	conf.setScope_name(scope_name);
	conf.setOption_name(option_name);
	conf.setValue(option_value);

	conf_queue.push_back(conf);
endfunction


function int axi_write_user_config_base::checkTrueFalseEnum(input int int_boolean);
   if(int_boolean < 2 && int_boolean > -1)
	   return int_boolean;
   else
	   		`uvm_warning("Conifiguration Wrapper","Incorrect boolean option")
	   return -1;

endfunction

function void axi_write_user_config_base::setConfigurations();
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
	int 								posibility;

	`uvm_component_utils(axi_write_user_conf_package)

	function new (string name, uvm_component parent);
		super.new(name, parent);
		user_conf = axi_write_user_config_base::type_id::create("ConfigurationBase", this);
	endfunction : new


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

	function void setPosibility(input int posibility);
		this.posibility = posibility;
	endfunction

	function int getPosibility();
		return this.posibility;
	endfunction

endclass



`endif