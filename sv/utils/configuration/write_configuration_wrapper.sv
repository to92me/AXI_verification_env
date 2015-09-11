`ifndef AXI_WRITE_CONFIGURATION_WRAPPER_SVH
`define AXI_WRITE_CONFIGURATION_WRAPPER_SVH


//------------------------------------------------------------------------------
//
// CLASS: axi_write_configuration_wrapper
//
//------------------------------------------------------------------------------

class axi_write_configuration_randomize;
	int 	confNO;
	int		confNO_queue[$];
	int 	confNO_posibility_queue[$];

	int sum;
	int lower_limit = 0;
	int upper_limit = 0;

	rand int sum_rand;

	constraint confNO_cs{
		sum_rand inside {[0 : sum]};
	}


	function void pre_randomize();
	 	sum = confNO_posibility_queue.sum();
	endfunction

	function void post_randomize();
		for (int i = 0; i < confNO_queue.size(); i++)
			begin
				upper_limit += confNO_posibility_queue[i];

				if(sum_rand >= lower_limit && sum_rand < upper_limit)
					begin
						confNO = i;
					end

				lower_limit += confNO_posibility_queue[i];
			end
	endfunction

	// Get confNO
	function int getConfNO();
		return confNO;
	endfunction


	// Set confNO_posibility_queue
	function void setConfNO_posibility_queue(input int_queue confNO_posibility_queue);
		this.confNO_posibility_queue = confNO_posibility_queue;
	endfunction


	// Set confNO_queue
	function void setConfNO_queue(input int_queue confNO_queue);
		this.confNO_queue = confNO_queue;
	endfunction



endclass



//------------------------------------------------------------------------------
//
// CLASS: axi_write_configuration_wrapper
//
//------------------------------------------------------------------------------



class axi_write_configuration_wrapper extends uvm_component;

	axi_write_conf								configuration_object;
	axi_write_configuration_register			register_user_conf;
	static 	axi_write_configuration_wrapper		wraper_instance;
	axi_write_user_conf_package					user_confs_queue[$];
	axi_write_user_config_base					current_config;



	// USER CONFIGURATION
	axi_write_config_field					master_data_conf[$];
	axi_write_config_field					master_addr_conf[$];
	axi_write_config_field					master_resp_conf[$];
	axi_write_config_field					slave_data_conf[$];
	axi_write_config_field					slave_addr_conf[$];
	axi_write_config_field					slave_resp_conf[$];
	axi_write_config_field					global_conf[$];
	axi_write_config_field					correct_value_conf[$];

	// ALL CONFIGURATIONS
	string 										master_data[$];
	string 										master_addr[$];
	string 										master_resp[$];
	string 										slave_data[$];
	string 										slave_resp[$];
	string 										slave_addr[$];
	string 										globalc[$];
	string										correct_value[$];


	// CONFIGURATIONS OBJECTS
	axi_write_global_conf					global_config_object;
	axi_write_correct_value_conf			correct_value_config_object;

	axi_write_buss_write_configuration		master_data_config_object;
	axi_write_buss_write_configuration		master_addr_config_object;
	axi_write_buss_read_configuration		master_resp_config_object;

	axi_write_buss_read_configuration		slave_data_config_object;
	axi_write_buss_read_configuration		slave_addr_config_object;
 	axi_write_buss_write_configuration		slave_resp_config_object;



	`uvm_component_utils(axi_write_configuration_wrapper)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);

		register_user_conf 				= axi_write_configuration_register::type_id::create("RegisterUserConfigurations", this);

		global_config_object 			= axi_write_global_conf::type_id::create(|"GlobalConfiguration", this);
		correct_value_config_object		= axi_write_correct_value_conf::type_id::create("ValidDataConfiguration", this);

		master_data_config_object		= axi_write_buss_write_configuration::type_id::create("MasterDataConfiguration", this);
		master_addr_config_object		= axi_write_buss_write_configuration::type_id::create("MasterAddrConfiguration", this);
		master_resp_config_object		= axi_write_buss_read_configuration::type_id::create("MasterRespConfiguraton", this);

		slave_data_config_object        = axi_write_buss_read_configuration::type_id::create("SlaveDataConfiguration", this);
		slave_addr_config_object		= axi_write_buss_read_configuration::type_id::create("SlaveAddrConfiguration", this);
		slave_resp_config_object		= axi_write_buss_write_configuration::type_id::create("SlaveRespConfiguration", this);

		configuration_object        	= axi_write_conf::type_id::create("AxiWriteConfiguration", this);

	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern function void init();

	extern function axi_write_conf generateConfigurationObject();
	extern function void checkUnsettedConfiguration();
	extern function void wrappConfigurationObject();

	extern static function axi_write_configuration_wrapper getWraperInstance(input uvm_component parent);

	extern function int registerConfiguration(input axi_write_user_config_base configuration_instance, true_false_enum valid_conf, int posibility);

	extern function void fillBusWriterConfiguration(ref string_queue bus_write_config_queue);
	extern function void fillBusReadConfiguration(ref string_queue bus_read_config_queue);
	extern function void fillCorrectValueConfiguration(ref string_queue correct_value_queue);
	extern function void fillOneCorrectValueConfiguration(input string conf_name, ref string_queue correct_value_queue );
	extern function void fillGlobalConfiguration(ref string_queue global_confing_queue);
	extern function void remoteOneCorrectValueConfiguration(input string conf_name, ref string_queue correct_value_queue);

	extern function void printStringQueue(input string_queue printing_queue);

	extern function void fillUserConfiguration();
	extern function true_false_enum checkIfOptionIsValid(input string option,  string_queue check_queue);
	extern function void getRandomConfiguration();

	extern function void parseUserGlobalConfiguration();
	extern function void parseUserCorrectValueConfiguration();
	extern function void parseUserBusWriteConfiguration(ref config_queue user_configuration, ref string_queue all_configurations,
														ref axi_write_buss_write_configuration config_object);
	extern function void parseUserBusReadConfiguration(ref config_queue user_configuration, ref string_queue all_configurations,
														ref axi_write_buss_read_configuration config_object );

	extern function true_false_enum removeStringFromQueue(input string string_to_delete,ref string_queue queue_from_to_delete );
	extern function void  setAllCorrectValue();
	extern function true_false_enum findeFullSpeedOption(input config_queue gueue_to_search, output int order_number);

	extern function true_false_enum parseCorrectValue(input string parse_string, output string value_name , string value_option);
	extern function true_false_enum setCorrectValueOptionField(input string option_name, string option_field, int value, axi_write_correct_one_value configuration_to_set  );




endclass : axi_write_configuration_wrapper




function axi_write_configuration_wrapper axi_write_configuration_wrapper::getWraperInstance(input uvm_component parent);
	if(wraper_instance == null)
		begin
			$display("AxiWriteConfigurationWrapper is created ");
			wraper_instance = new("AxiWriteConfigurationWrapper", parent);
		end
	return wraper_instance;
endfunction

function int axi_write_configuration_wrapper::registerConfiguration(input axi_write_user_config_base configuration_instance, true_false_enum valid_conf, int posibility);
 	axi_write_user_conf_package conf;

	conf = axi_write_user_conf_package::type_id::create("ConfigurationPackage", this);

	conf.setConf_id(this.user_confs_queue.size());
	conf.setValid_configuration(valid_conf);
	conf.setUser_conf(configuration_instance);
	conf.setPosibility(posibility);

	this.user_confs_queue.push_front(conf);
	return conf.getConf_id();
endfunction


function void  axi_write_configuration_wrapper::init();
	fillBusWriterConfiguration(this.master_data);
	fillBusWriterConfiguration(this.master_addr);
	fillBusReadConfiguration(this.master_resp);

	fillBusReadConfiguration(this.slave_data);
	fillBusReadConfiguration(this.slave_addr);
	fillBusWriterConfiguration(this.slave_resp);

	fillGlobalConfiguration(this.globalc);
	fillCorrectValueConfiguration(this.correct_value);

	$display("master_data:");
	printStringQueue(master_data);
	$display("master_addr:");
	printStringQueue(master_addr);
	$display("master_resp:");
	printStringQueue(master_resp);

	$display("slave_data:");
	printStringQueue(slave_data);
	$display("slave_addr:");
	printStringQueue(slave_addr);
	$display("slave_resp:");
	printStringQueue(slave_resp);

	$display("globalc:");
	printStringQueue(globalc);
	$display("correct_value:");
	printStringQueue(correct_value);
endfunction


function void axi_write_configuration_wrapper::fillBusWriterConfiguration(ref string_queue bus_write_config_queue);
	bus_write_config_queue.push_front("full_speed");
	bus_write_config_queue.push_front("valid_delay_minimum");
	bus_write_config_queue.push_front("valid_delay_maximum");
	bus_write_config_queue.push_front("valid_delay_exists");
	bus_write_config_queue.push_front("valid_delay_constant");
	bus_write_config_queue.push_front("valid_delay_constate_value");
endfunction

function void axi_write_configuration_wrapper::fillBusReadConfiguration(ref string_queue bus_read_config_queue);
	bus_read_config_queue.push_front("full_speed");
	bus_read_config_queue.push_front("ready_delay_exists");
	bus_read_config_queue.push_front("ready_delay_constant");
	bus_read_config_queue.push_front("ready_delay_constant_value");
	bus_read_config_queue.push_front("ready_delay_minimum");
	bus_read_config_queue.push_front("ready_delay_maximum");
	bus_read_config_queue.push_front("ready_constant");
	bus_read_config_queue.push_front("ready_constant_value");
	bus_read_config_queue.push_front("ready_posibility_of_0");
	bus_read_config_queue.push_front("ready_posibility_of_1");
endfunction

function void axi_write_configuration_wrapper::fillCorrectValueConfiguration(ref string_queue correct_value_queue);
	fillOneCorrectValueConfiguration("awid",correct_value_queue );
	fillOneCorrectValueConfiguration("awregion",correct_value_queue );
	fillOneCorrectValueConfiguration("awlen",correct_value_queue );
	fillOneCorrectValueConfiguration("awsize",correct_value_queue );
	fillOneCorrectValueConfiguration("awburst",correct_value_queue );
	fillOneCorrectValueConfiguration("awlock",correct_value_queue );
	fillOneCorrectValueConfiguration("awcache",correct_value_queue );
	fillOneCorrectValueConfiguration("awqos",correct_value_queue );
	fillOneCorrectValueConfiguration("wstrb",correct_value_queue );
	fillOneCorrectValueConfiguration("bresp",correct_value_queue );
endfunction

function void axi_write_configuration_wrapper::fillOneCorrectValueConfiguration(input string conf_name, ref string_queue correct_value_queue);
	string full_name;

	full_name = $sformatf("%s_mode", conf_name);
	correct_value_queue.push_front(full_name);

	full_name = $sformatf("%s_dist_correct", conf_name);
	correct_value_queue.push_front(full_name);

	full_name = $sformatf("%s_dist_incorrect", conf_name);
	correct_value_queue.push_front(full_name);

endfunction

function void axi_write_configuration_wrapper::remoteOneCorrectValueConfiguration(input string conf_name, ref string_queue correct_value_queue);
	string full_name;

   	full_name = $sformatf("%s_mode", conf_name);
	void'(removeStringFromQueue(full_name,correct_value_queue));

	full_name = $sformatf("%s_dist_correct", conf_name);
	void'(removeStringFromQueue(full_name,correct_value_queue));

	full_name = $sformatf("%s_dist_incorrect", conf_name);
    void'(removeStringFromQueue(full_name,correct_value_queue));

endfunction


function void axi_write_configuration_wrapper::fillGlobalConfiguration(ref string_queue global_confing_queue);
	global_confing_queue.push_front("do_coverage");
	global_confing_queue.push_front("do_checks");
	global_confing_queue.push_front("correct_driving_vif");
	global_confing_queue.push_front("axi_3_support");
	global_confing_queue.push_front("master_write_deepth");
	global_confing_queue.push_front("full_speed");
	global_confing_queue.push_front("delay_between_burst_packages");
	global_confing_queue.push_front("delay_addr_package");
	global_confing_queue.push_front("delay_data_package");
	global_confing_queue.push_front("delay_between_packages_minimum");
	global_confing_queue.push_front("delay_between_packages_maximum");
	global_confing_queue.push_front("delay_between_packages_constant");

endfunction


function void axi_write_configuration_wrapper::printStringQueue(input string_queue printing_queue);
	for(int i = 0; i < printing_queue.size(); i++ )
		begin
			$display(" %d, %s", i, printing_queue[i]);
		end
endfunction

function void axi_write_configuration_wrapper::getRandomConfiguration();
	axi_write_configuration_randomize random;
	int random_queue[$];
	int random_posibility_queue[$];
	int i;

	random = new();

	foreach(this.user_confs_queue[i])
		begin
			if(user_confs_queue[i].getValid_configuration() == TRUE)
				begin
					random_queue.push_front(user_confs_queue[i].getConf_id());
					random_posibility_queue.push_front(user_confs_queue[i].getPosibility());
				end
		end

	random.setConfNO_queue(random_queue);
	random.setConfNO_posibility_queue(random_posibility_queue);
	assert(random.randomize());

	//when random configuration is chosen use it to fill current_config
	current_config = user_confs_queue[random.getConfNO()].getUser_conf();

endfunction


function void axi_write_configuration_wrapper::fillUserConfiguration();
	axi_write_config_field all_configs[$];
	int i;
	string scope;
	string option;

	$display("======================== PARSEING SCOPE ================================");

	all_configs = current_config.getConfQueue();

	foreach(all_configs[i])
		begin
			scope = all_configs[i].getScope_name();
			option = all_configs[i].getOption_name();

			if(scope.icompare("general") == 0)
			begin
				if(checkIfOptionIsValid(option, globalc) == TRUE)
					begin
						global_conf.push_front(all_configs[i]);
						$display("scope %s added t global_conf", scope);
					end
				else
					begin
						$display("scope: %s OK, option: %s invalid", scope, option);
					end
			end

			else if(scope.icompare("data_correctnes") == 0)
			begin
				if(checkIfOptionIsValid(option, correct_value) == TRUE)
					begin
						correct_value_conf.push_front(all_configs[i]);
						$display("scope %s added to correct_value_conf", scope);
					end
				else
					begin
						$display("scope: %s OK, option: %s invalid", scope, option);
					end
			end

			else if(scope.icompare("master_data_driver") == 0)
			begin
				if(checkIfOptionIsValid(option, master_data) == TRUE)
					begin
						master_data_conf.push_front(all_configs[i]);
						$display("scope %s added to master_data_conf", scope);
					end
				else
					begin
						$display("scope: %s OK, option: %s invalid", scope, option);
					end
			end

			else if(scope.icompare("master_addr_driver") == 0)
			begin
				if(checkIfOptionIsValid(option, master_addr) == TRUE)
					begin
						master_addr_conf.push_front(all_configs[i]);
						$display("scope %s added to master_addr_conf", scope);
					end
				else
					begin
						$display("scope: %s OK, option: %s invalid", scope, option);
					end
			end

			else if(scope.icompare("master_resp_driver") == 0)
			begin
				if(checkIfOptionIsValid(option, master_resp) == TRUE)
					begin
						master_resp_conf.push_front(all_configs[i]);
						$display("scope %s added to master_resp_conf", scope);
					end
				else
					begin
						$display("scope: %s OK, option: %s invalid", scope, option);
					end
			end

			else if(scope.icompare("slave_data_driver") == 0)
			begin
				if(checkIfOptionIsValid(option, slave_data) == TRUE)
					begin
						slave_data_conf.push_front(all_configs[i]);
						$display("scope %s added to slave_data_conf", scope);
					end
				else
					begin
						$display("scope: %s OK, option: %s invalid", scope, option);
					end
			end

			else if(scope.icompare("slave_addr_driver") == 0)
			begin
				if(checkIfOptionIsValid(option, slave_addr) == TRUE)
					begin
						slave_addr_conf.push_front(all_configs[i]);
						$display("scope %s added to slave_addr_conf", scope);
					end
				else
					begin
						$display("scope: %s OK, option: %s invalid", scope, option);
					end
			end

			else if(scope.icompare("slave_resp_driver") == 0)
			begin
				if(checkIfOptionIsValid(option, slave_resp) == TRUE)
					begin
						slave_resp_conf.push_front(all_configs[i]);
						$display("scope %s added to slave_resp_driver", scope);
					end
				else
					begin
							$display("scope: %s OK, option: %s invalid", scope, option);
					end
			end

			else
			begin
				$display("WARNING: Register configuration scope is not valid: %s",all_configs[i].getScope_name());
			end

		end

			$display("======================== END SCOPE ================================");
endfunction


function axi_write_conf axi_write_configuration_wrapper::generateConfigurationObject();
	this.init();

	// to create configuration object first randomize configuration;
	this.register_user_conf.registerConfig();
	this.getRandomConfiguration();

	//then split configurations to corresponding scope
	this.fillUserConfiguration();

	// parse everithing
	this.parseUserGlobalConfiguration();
	this.parseUserCorrectValueConfiguration();

	this.parseUserBusWriteConfiguration(master_data_conf, master_data, master_data_config_object);
	this.parseUserBusWriteConfiguration(master_addr_conf, master_addr, master_addr_config_object);
	this.parseUserBusReadConfiguration(master_resp_conf, master_resp, master_resp_config_object);

	this.parseUserBusReadConfiguration(slave_data_conf, slave_data, slave_data_config_object);
	this.parseUserBusReadConfiguration(slave_addr_conf, slave_addr, slave_data_config_object);
	this.parseUserBusWriteConfiguration(slave_resp_conf, slave_resp, slave_resp_config_object);

	//check for not setted configurations
	this.checkUnsettedConfiguration();

	//wrapp configuration in configuratin object;
	this.wrappConfigurationObject();

	return configuration_object;

endfunction

function void axi_write_configuration_wrapper::parseUserGlobalConfiguration();
	int i;
	string option;
	$display("=======================PARSING GLOBAL CONF=======================");
	foreach(global_conf[i])
		begin
			option = global_conf[i].getOption_name();
			$display("option: %s",option);
			if(removeStringFromQueue(option,globalc) == TRUE)
			begin

// DO_COVERAGE OPTION
				if(option.icompare("do_coverage") == 0)
				begin
					if(global_conf[i].getValue() == 1)
						begin
							global_config_object.setDo_coverage(TRUE);
							$display(" Do_coverage = TRUE ");
						end
					else
						begin
							global_config_object.setDo_coverage(FALSE);
							$display(" Do_coverage = FALSE ");
						end
				end

	// DO_CHECKS OPTION
				else if(option.icompare("do_checks") == 0)
					begin
							global_config_object.setDo_checks(global_conf[i].getValue());
							$display("do_checks : %d",global_config_object.getDo_checks());
					end

	//CORRECT DRIVING VIF OPTION
				else if(option.icompare("correct_driving_vif") == 0)
					begin
						global_config_object.setCorrect_driving_vif(global_conf[i].getValue());
						$display("correct_driving_vif : %0d",global_config_object.getCorrect_driving_vif());
						if(global_config_object.getCorrect_driving_vif() == TRUE)
							begin
								setAllCorrectValue();
							end
					end

	//AXI_3_SUPPORT OPTION
				else if(option.icompare("axi_3_support") == 0)
					begin
						global_config_object.setAxi_3_support(global_conf[i].getValue());
						$display("setAxi_3_support : %d",global_config_object.getAxi_3_support());
						if(global_config_object.getAxi_3_support() == FALSE)
							begin
								global_config_object.setMaster_write_deepth(0);
								$display("setMaster_write_deepth : %d",global_config_object.getMaster_write_deepth());
								void'(removeStringFromQueue("master_write_deepth", globalc));
							end
					end

// MASTER_DEEPTH
			else if(option.icompare("master_write_deepth") == 0)
				begin
					global_config_object.setMaster_write_deepth(global_conf[i].getValue());
					$display("setMaster_write_deepth : %d",global_config_object.getMaster_write_deepth());
				end

//FULL SPEED
			else if(option.icompare("full_speed") == 0)
				begin

					global_config_object.setDelay_between_burst_packages(FALSE);
					void'(removeStringFromQueue("delay_between_burst_packages", globalc));
					void'(removeStringFromQueue("delay_between_packages_minimum", globalc));
					void'(removeStringFromQueue("delay_between_packages_maximum", globalc));
					void'(removeStringFromQueue("delay_between_packages_constant", globalc));

					global_config_object.setDelay_between_burst_packages(0);
					global_config_object.setDelay_addr_package(FALSE);
					void'(removeStringFromQueue("delay_addr_package", globalc));
					global_config_object.setDelay_data_package(FALSE);
					void'(removeStringFromQueue("delay_data_package", globalc));

					master_resp_config_object.setReady_constant(TRUE);
					master_resp_config_object.setReady_const_value(1);
					master_resp_config_object.setReady_delay_exists(FALSE);

					void'(removeStringFromQueue("full_speed", master_resp));
					void'(removeStringFromQueue("ready_delay_exists", master_resp));
					void'(removeStringFromQueue("ready_delay_constant", master_resp));
					void'(removeStringFromQueue("ready_delay_const_value", master_resp));
					void'(removeStringFromQueue("ready_delay_minimum", master_resp));
					void'(removeStringFromQueue("ready_delay_maximum", master_resp));
					void'(removeStringFromQueue("ready_constant", master_resp));
					void'(removeStringFromQueue("ready_constant", master_resp));
					void'(removeStringFromQueue("ready_constant_value", master_resp));
					void'(removeStringFromQueue("ready_posibility_of_0", master_resp));
					void'(removeStringFromQueue("ready_posibility_of_1", master_resp));


					slave_data_config_object.setReady_constant(TRUE);
					slave_data_config_object.setReady_const_value(1);
					slave_data_config_object.setReady_delay_exists(FALSE);

					void'(removeStringFromQueue("full_speed", slave_data));
					void'(removeStringFromQueue("ready_delay_exists", slave_data));
					void'(removeStringFromQueue("ready_delay_constant", slave_data));
					void'(removeStringFromQueue("ready_delay_const_value", slave_data));
					void'(removeStringFromQueue("ready_delay_minimum", slave_data));
					void'(removeStringFromQueue("ready_delay_maximum", slave_data));
					void'(removeStringFromQueue("ready_constant", slave_data));
					void'(removeStringFromQueue("ready_constant_value", slave_data));
					void'(removeStringFromQueue("ready_posibility_of_0", slave_data));
					void'(removeStringFromQueue("ready_posibility_of_1", slave_data));


					slave_addr_config_object.setReady_constant(TRUE);
					slave_addr_config_object.setReady_const_value(1);
					slave_addr_config_object.setReady_delay_exists(FALSE);

					void'(removeStringFromQueue("full_speed", slave_addr));
					void'(removeStringFromQueue("ready_delay_exists", slave_addr));
					void'(removeStringFromQueue("ready_delay_constant", slave_addr));
					void'(removeStringFromQueue("ready_delay_const_value", slave_addr));
					void'(removeStringFromQueue("ready_delay_minimum", slave_addr));
					void'(removeStringFromQueue("ready_delay_maximum", slave_addr));
					void'(removeStringFromQueue("ready_constant", slave_addr));
					void'(removeStringFromQueue("ready_constant_value", slave_addr));
					void'(removeStringFromQueue("ready_posibility_of_0", slave_addr));
					void'(removeStringFromQueue("ready_posibility_of_1", slave_addr));


					master_data_config_object.setValid_delay_exists(FALSE);

					void'(removeStringFromQueue("full_speed", master_data));
					void'(removeStringFromQueue("valid_delay_exists", master_data));
					void'(removeStringFromQueue("valid_delay_maximum", master_data));
					void'(removeStringFromQueue("valid_delay_minimum", master_data));
					void'(removeStringFromQueue("valid_contant_delay_value", master_data));
					void'(removeStringFromQueue("valid_constant_delay", master_data));


					master_addr_config_object.setValid_delay_exists(FALSE);

					void'(removeStringFromQueue("full_speed", master_addr));
					void'(removeStringFromQueue("valid_delay_exists", master_addr));
					void'(removeStringFromQueue("valid_delay_maximum", master_addr));
					void'(removeStringFromQueue("valid_delay_minimum", master_addr));
					void'(removeStringFromQueue("valid_contant_delay_value", master_addr));
					void'(removeStringFromQueue("valid_constant_delay", master_addr));


					slave_resp_config_object.setValid_delay_exists(FALSE);

					void'(removeStringFromQueue("full_speed", slave_resp));
					void'(removeStringFromQueue("valid_delay_exists", slave_resp));
					void'(removeStringFromQueue("valid_delay_maximum", slave_resp));
					void'(removeStringFromQueue("valid_delay_minimum", slave_resp));
					void'(removeStringFromQueue("valid_contant_delay_value", slave_resp));
					void'(removeStringFromQueue("valid_constant_delay", slave_resp));

				end

// DELAY BETWEAN BURSTS PACKAGES
			else if(option.icompare("delay_between_burst_packages") == 0)
				begin
					global_config_object.setDelay_between_burst_packages(global_conf[i].getValue());
					$display("delay_between_burst_packages : %d",global_config_object.getDelay_between_burst_packages());
				end

// DELAY BETWEEN BURSTS PACKAGES MINIMUM
			else if(option.icompare("delay_between_packages_minimum") == 0)
				begin
					global_config_object.setDelay_between_packages_minimum(global_conf[i].getValue());
					$display("delay_between_packages_minimum : %d",global_config_object.getDelay_between_packages_minimum());
				end

// DELAY BETWEEN BURSTS PACKAGES MAXIMUM
			else if(option.icompare("delay_between_packages_maximum") == 0)
				begin
					global_config_object.setDelay_between_packages_maximum(global_conf[i].getValue());
					$display("delay_between_packages_maximum : %d",global_config_object.getDelay_between_packages_maximum());
				end

// DELAY BETWEEN BURSTS PACKAGES CONSTANT
			else if(option.icompare("delay_between_packages_constant") == 0)
				begin
					global_config_object.setDelay_between_packages_constant(global_conf[i].getValue());
					$display("delay_between_packages_constant : %d",global_config_object.getDelay_between_packages_constant());
				end

// DELAY ADDR PACKAGE
			else if(option.icompare("delay_addr_package") == 0)
				begin
					global_config_object.setDelay_addr_package(global_conf[i].getValue());
					$display("delay_addr_package : %d",global_config_object.getDelay_addr_package());
				end

//DELAY DATA PACKAGE
			else if(option.icompare("delay_data_package") == 0)
				begin
					global_config_object.setDelay_data_package(global_conf[i].getValue());
					$display("delay_data_package : %d",global_config_object.getDelay_data_package());
				end

			end
		else
			begin
				`uvm_info("Configuration Wrapper [U]: ",$sformatf("%s option alredy set", option ), UVM_WARNING)
			end
		end // end foreach

	$display("=======================END GLOBAL CONF=======================");

endfunction


function void axi_write_configuration_wrapper::parseUserCorrectValueConfiguration();
    int i;
	string option;
	string option_name;
	string option_field;
	axi_write_correct_one_value new_correct_config;

		$display("=======================PARSING CORRECT VALUE=======================");


	foreach(correct_value_conf[i])
		begin
			option = correct_value_conf[i].getOption_name();
// CHECK IF IT IS ALREADY SET
			if(removeStringFromQueue(option, correct_value) == TRUE)
				begin
// PARSE IT
					if(parseCorrectValue(option, option_name, option_field) == TRUE)
						begin

// OPTION AWID
							if(option_name.icompare("awid") == 0)
								begin
									new_correct_config = correct_value_config_object.getAwid_conf();
									if (new_correct_config == null )
										begin
											new_correct_config = new();
										end
									void'(setCorrectValueOptionField(option_name, option_field, correct_value_conf[i].getValue(), new_correct_config));
								end

// OPTION AWREAGION
							else if(option_name.icompare("awregion") == 0)
								begin
									new_correct_config = correct_value_config_object.getAwregion_conf();
									if (new_correct_config == null )
										begin
											new_correct_config = new();
										end
									void'(setCorrectValueOptionField(option_name, option_field, correct_value_conf[i].getValue(), new_correct_config));
								end

// OPTION AWLEN
							else if(option_name.icompare("awlen") == 0)
								begin
									new_correct_config = correct_value_config_object.getAwlen_conf();
									if (new_correct_config == null )
										begin
											new_correct_config = new();
										end
									void'(setCorrectValueOptionField(option_name, option_field, correct_value_conf[i].getValue(), new_correct_config));
								end

// OPTION AWSIZE
							else if(option_name.icompare("awsize") == 0)
								begin
									new_correct_config = correct_value_config_object.getAwsize_conf();
									if (new_correct_config == null )
										begin
											new_correct_config = new();
										end
									void'(setCorrectValueOptionField(option_name, option_field, correct_value_conf[i].getValue(), new_correct_config));
								end

// OPTION AWBURST
							else if(option_name.icompare("awburst") == 0)
								begin
									new_correct_config = correct_value_config_object.getAwburst_conf();
									if (new_correct_config == null )
										begin
											new_correct_config = new();
										end
									void'(setCorrectValueOptionField(option_name, option_field, correct_value_conf[i].getValue(), new_correct_config));
								end

//OPTION AWLOCK
							else if(option_name.icompare("awlock") == 0)
								begin
									new_correct_config = correct_value_config_object.getAwlock_conf();
									if (new_correct_config == null )
										begin
											new_correct_config = new();
										end
									void'(setCorrectValueOptionField(option_name, option_field, correct_value_conf[i].getValue(), new_correct_config));
								end

// OPTION AWQOS
							else if(option_name.icompare("awqos") == 0)
								begin
									new_correct_config = correct_value_config_object.getAwqos_conf();
									if (new_correct_config == null )
										begin
											new_correct_config = new();
										end
									void'(setCorrectValueOptionField(option_name, option_field, correct_value_conf[i].getValue(), new_correct_config));
								end

// OPTION AWCACHE
							else if(option_name.icompare("awcache") == 0)
								begin
									new_correct_config = correct_value_config_object.getAwcache_conf();
									if (new_correct_config == null )
										begin
											new_correct_config = new();
										end
									void'(setCorrectValueOptionField(option_name, option_field, correct_value_conf[i].getValue(), new_correct_config));
								end

// OPTION AWSTRB
							else if(option_name.icompare("wstrb") == 0)
								begin
									new_correct_config = correct_value_config_object.getWstrb_conf();
									if (new_correct_config == null )
										begin
											new_correct_config = new();
										end
									void'(setCorrectValueOptionField(option_name, option_field, correct_value_conf[i].getValue(), new_correct_config));
								end

// OPTION BRESP
							else if(option_name.icompare("bresp") == 0)
								begin
									new_correct_config = correct_value_config_object.getBresp_conf();
									if (new_correct_config == null )
										begin
											new_correct_config = new();
										end
									void'(setCorrectValueOptionField(option_name, option_field, correct_value_conf[i].getValue(), new_correct_config));
								end

// ELSE WRONG OPTION
							else
								begin
									`uvm_info("Configuration Wrapper [U] tome : ",$sformatf("%s invalid argument", option_name), UVM_WARNING)
								end


						end
				end
			else
				begin
					`uvm_info("Configuration Wrapper [U]: ",$sformatf("%s option alredy set", option ), UVM_WARNING)
				end
		end //end foreach

		$display("=======================END  CORRECT VALUE=======================");


endfunction


function void axi_write_configuration_wrapper::parseUserBusReadConfiguration(ref config_queue user_configuration, ref string_queue all_configurations,
														ref axi_write_buss_read_configuration config_object);
	int i;
	string option;
	int order_number;

		$display("========================= PARSING BUS READ CONF =================================");

	if(findeFullSpeedOption(user_configuration, order_number) == TRUE)
		begin
			axi_write_config_field tmp_conf;
			tmp_conf = new();
			tmp_conf = user_configuration[order_number];
			user_configuration.delete(order_number);
			user_configuration.push_front(tmp_conf);
		end


	foreach(user_configuration[i])
		begin
			option = user_configuration[i].getOption_name();

			if(removeStringFromQueue(option, all_configurations) == TRUE)
				begin
// ready_delay_exists
					if(option.icompare("ready_delay_exists") == 0)
						begin
							config_object.setReady_delay_exists(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("Ready_delay_exists. %d", config_object.getReady_delay_exists()), UVM_LOW);
						end

//ready_delay_constant
					else if(option.icompare("ready_delay_constant") == 0)
						begin
							config_object.setReady_delay_constant(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("setReady_delay_constant. %d", config_object.getReady_delay_constant()), UVM_LOW);
						end

//ready_delay_const_value
					else if(option.icompare("ready_delay_const_value") == 0)
						begin
							config_object.setReady_delay_const_value(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("setReady_delay_const_value. %d", config_object.getReady_delay_const_value()), UVM_LOW);
						end

//ready_delay_minimum
					else if(option.icompare("ready_delay_minimum") == 0)
						begin
							config_object.setReady_delay_minimum(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("setReady_delay_minimum. %d", config_object.getReady_delay_minimum()), UVM_LOW);
						end

//ready_delay_maximum
					else if(option.icompare("ready_delay_maximum") == 0)
						begin
							config_object.setReady_delay_maximum(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("ready_delay_maximum. %d", config_object.getReady_delay_maximum()),UVM_LOW);
						end

//ready_constant
					else if(option.icompare("ready_constant") == 0)
						begin
							config_object.setReady_constant(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("ready_constant. %d", config_object.getReady_constant()),UVM_LOW);
						end

//ready_const_value
					else if(option.icompare("ready_const_value") == 0)
						begin
							config_object.setReady_const_value(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("ready_const_value. %d", config_object.getReady_const_value()),UVM_LOW);
						end

//ready_posibility_of_0
					else if(option.icompare("ready_posibility_of_0") == 0)
						begin
							config_object.setReady_posibility_of_0(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("ready_posibility_of_0. %d", config_object.getReady_posibility_of_0()),UVM_LOW);
						end

//ready_posibility_of_1
					else if(option.icompare("ready_posibility_of_1") == 0)
						begin
							config_object.setReady_posibility_of_1(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("setReady_posibility_of_1. %d", config_object.getReady_posibility_of_1()),UVM_LOW);
						end

					else if(option.icompare("full_speed") == 0)
						begin
							$display("configurationt wrapper [U]: Bus Write:  full_speed option: setting all parameters");
							config_object.setReady_constant(TRUE);
							config_object.setReady_const_value(1);
							config_object.setReady_delay_exists(FALSE);

							void'(removeStringFromQueue("ready_delay_exists", all_configurations));
							void'(removeStringFromQueue("ready_delay_constant", all_configurations));
							void'(removeStringFromQueue("ready_delay_const_value", all_configurations));
							void'(removeStringFromQueue("ready_delay_minimum", all_configurations));
							void'(removeStringFromQueue("ready_delay_maximum", all_configurations));
							void'(removeStringFromQueue("ready_constant", all_configurations));
							void'(removeStringFromQueue("ready_constant_value", all_configurations));
							void'(removeStringFromQueue("ready_posibility_of_0", all_configurations));
							void'(removeStringFromQueue("ready_posibility_of_1", all_configurations));

						end


// ELSE INVALID
					else
						begin
							`uvm_info("Configuration Wrapper [U]: ",$sformatf("%s invalid argument", option ), UVM_WARNING)
						end

				end
			else
				begin
					`uvm_info("Configuration Wrapper [U]: ",$sformatf("%s option alredy set", option ), UVM_WARNING)
				end
		end

			$display("========================= END BUS WRITE CONF =================================");


endfunction


function void axi_write_configuration_wrapper::parseUserBusWriteConfiguration(ref config_queue user_configuration, ref string_queue all_configurations,
																				ref axi_write_buss_write_configuration config_object);

	int i;
	string option;
	int order_number;

	$display("========================= PARSIN BUS WRITE CONF =================================");

	if(findeFullSpeedOption(user_configuration, order_number) == TRUE)
		begin
			axi_write_config_field tmp_conf;
			tmp_conf = new();
			tmp_conf = user_configuration[order_number];
			user_configuration.delete(order_number);
			user_configuration.push_front(tmp_conf);
		end

	foreach(user_configuration[i])
		begin
			option = user_configuration[i].getOption_name();

			if(removeStringFromQueue(option, all_configurations) == TRUE)
				begin

//valid_delay_exists
					if(option.icompare("valid_delay_exists") == 0)
						begin
							config_object.setValid_delay_exists(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("valid_delay_exists. %d", config_object.getValid_delay_exists()),UVM_LOW);
						end

//valid_constant_delay
					else if(option.icompare("valid_constant_delay") == 0)
						begin
							config_object.setValid_constant_delay(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("valid_constant_delay. %d", config_object.getValid_constant_delay()),UVM_LOW);
						end

//valid_contant_delay_value
					else if(option.icompare("valid_contant_delay_value") == 0)
						begin
							config_object.setValid_contant_delay_value(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("valid_contant_delay_value. %d", config_object.getValid_contant_delay_value()),UVM_LOW);
						end

//valid_delay_minimum
					else if(option.icompare("valid_delay_minimum") == 0)
						begin
							config_object.setDelay_minimum(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("valid_delay_minimum. %d", config_object.getDelay_minimum()),UVM_LOW);
						end

//valid_delay_maximum
					else if(option.icompare("valid_delay_maximum") == 0)
						begin
							config_object.setDelay_maximum(user_configuration[i].getValue());
							`uvm_info("configurationt wrapper [U]: ",$sformatf("valid_delay_maximum. %d", config_object.getDelay_maximum()),UVM_LOW);
						end

//FULL SPEED OPTION
					else if(option.icompare("full_speed") == 0)
						begin
							$display("configurationt wrapper [U]: Bus Write: full_speed option: setting all parameters");
							config_object.setValid_delay_exists(FALSE);

							void'(removeStringFromQueue("valid_delay_exists", all_configurations));
							void'(removeStringFromQueue("valid_delay_maximum", all_configurations));
							void'(removeStringFromQueue("valid_delay_minimum", all_configurations));
							void'(removeStringFromQueue("valid_contant_delay_value", all_configurations));
							void'(removeStringFromQueue("valid_constant_delay", all_configurations));
						end

// ELSE WRONG OPTION
					else
						begin
							`uvm_info("Configuration Wrapper [U]: ",$sformatf("%s invalid argument", option ), UVM_WARNING)
						end

				end
			else
				begin
					`uvm_info("Configuration Wrapper [U]: ",$sformatf("%s option alredy set", option ), UVM_WARNING)
				end
		end //endforeach

			$display("========================= END BUS WRITE CONF =================================");


endfunction

function true_false_enum axi_write_configuration_wrapper::removeStringFromQueue(input string string_to_delete, ref string_queue queue_from_to_delete);
	int tmp_i  = -1;

	$display("removeing string: %s",string_to_delete);

	for(int i = 0; i < queue_from_to_delete.size(); i++)
		begin
	    	if(string_to_delete.icompare(queue_from_to_delete[i]) == 0)
		    	begin
			    	tmp_i = i;
		    	end
		end
	if(tmp_i != -1)
		begin
			queue_from_to_delete.delete(tmp_i);
			return TRUE;
		end
	else
		return FALSE;
endfunction

function void axi_write_configuration_wrapper::setAllCorrectValue();
	axi_write_correct_one_value correct_driving;
	correct_driving = new();

	correct_driving.setMode(1);

	correct_value_config_object.setAwburst_conf(correct_driving);
	correct_value_config_object.setAwcache_conf(correct_driving);
	correct_value_config_object.setAwid_conf(correct_driving);
	correct_value_config_object.setAwlen_conf(correct_driving);
	correct_value_config_object.setAwlock_conf(correct_driving);
	correct_value_config_object.setAwqos_conf(correct_driving);
	correct_value_config_object.setAwregion_conf(correct_driving);
	correct_value_config_object.setAwsize_conf(correct_driving);
	correct_value_config_object.setBresp_conf(correct_driving);
	correct_value_config_object.setWstrb_conf(correct_driving);

	remoteOneCorrectValueConfiguration("awid", correct_value);
	remoteOneCorrectValueConfiguration("awregion", correct_value);
	remoteOneCorrectValueConfiguration("awlen", correct_value);
	remoteOneCorrectValueConfiguration("awburst", correct_value);
	remoteOneCorrectValueConfiguration("awsize", correct_value);
	remoteOneCorrectValueConfiguration("awlock", correct_value);
	remoteOneCorrectValueConfiguration("awcache", correct_value);
	remoteOneCorrectValueConfiguration("awqos", correct_value);
	remoteOneCorrectValueConfiguration("wstrb", correct_value);
	remoteOneCorrectValueConfiguration("bresp", correct_value);

	`uvm_info(get_name(),"Setting all Correct value becuse correct_axi is setted ", UVM_LOW)

endfunction

function true_false_enum axi_write_configuration_wrapper::parseCorrectValue(input string parse_string, output string value_name, output string value_option);

	for(int i = 0; i < parse_string.len(); i++)
		begin
			if(parse_string.getc(i) == "_")
				begin
					value_name = parse_string.substr(0, i-1);
					value_option = parse_string.substr(i+1, parse_string.len()-1);
					$display("original: %s, separated: %s %s", parse_string,value_name,value_option );
					return TRUE;
				end
		end

		`uvm_info("CONFIGURATION VRAPPER [U]: ",$sformatf("invaild correct_value option, format shoul be <value>_<option> : %s ", parse_string), UVM_WARNING)
		return FALSE;

endfunction

function true_false_enum axi_write_configuration_wrapper::setCorrectValueOptionField(input string option_name, string option_field, int value,
	 axi_write_correct_one_value configuration_to_set);

	 if(option_field.icompare("mode") == 0)
		 begin
			 configuration_to_set.setMode(value);
			 `uvm_info("Configuration Wrapper [U]: ",$sformatf("%s _ %s : %0d", option_name, option_field, value ), UVM_LOW)
			 return TRUE;
		 end
	 else if(option_field.icompare("dist_correct") == 0)
		 begin
			 configuration_to_set.setDist_correct(value);
			 `uvm_info("Configuration Wrapper [U]: ",$sformatf("%s _ %s : %0d", option_name, option_field, value ), UVM_LOW)
			  return TRUE;
		 end
	 else if(option_field.icompare("dist_incorrect") == 0)
		 begin
			 configuration_to_set.setDist_incorrect(value);
			 `uvm_info("Configuration Wrapper [U]: ",$sformatf("%s _ %s : %0d", option_name, option_field, value ), UVM_LOW)
			 return TRUE;
		 end
	 else
		 begin
		 	`uvm_info("Configuration Wrapper [U]: ",$sformatf("%s _ %s : invalid format", option_name, option_field, value ), UVM_WARNING)
		 	return FALSE;
		 end
endfunction


function void axi_write_configuration_wrapper::checkUnsettedConfiguration();
	int i;
	foreach(master_data[i])
		begin
			$display("Configuration unsetted : %s, ussing default configuration", master_data[i]);
//			`uvm_info("ConfigurationWrapper [U]: ",$sformatf("Configuration unsetted : %s, ussing default configuration", master_data[i]), UVM_INFO);
		end

	foreach(master_addr[i])
		begin
			$display("Configuration unsetted : %s, ussing default configuration", master_data[i]);
//			`uvm_info("ConfigurationWrapper [U]: ",$sformatf("Configuration unsetted : %s, ussing default configuration", master_addr[i]), UVM_INFO);
		end

	foreach(master_resp[i])
		begin
			$display("Configuration unsetted : %s, ussing default configuration", master_data[i]);
//			`uvm_info("ConfigurationWrapper [U]: ",$sformatf("Configuration unsetted : %s, ussing default configuration", master_resp[i]), UVM_INFO);
		end

	foreach(slave_data[i])
		begin
			$display("Configuration unsetted : %s, ussing default configuration", master_data[i]);
//			`uvm_info("ConfigurationWrapper [U]: ",$sformatf("Configuration unsetted : %s, ussing default configuration", slave_data[i]), UVM_INFO);
		end

	foreach(slave_addr[i])
		begin
			$display("Configuration unsetted : %s, ussing default configuration", master_data[i]);
//			`uvm_info("ConfigurationWrapper [U]: ",$sformatf("Configuration unsetted : %s, ussing default configuration", slave_addr[i]), UVM_INFO);
		end

	foreach(slave_resp[i])
		begin
			$display("Configuration unsetted : %s, ussing default configuration", master_data[i]);
//			`uvm_info("ConfigurationWrapper [U]: ",$sformatf("Configuration unsetted : %s, ussing default configuration", slave_resp[i]), UVM_INFO);
		end
endfunction

function void axi_write_configuration_wrapper::wrappConfigurationObject();

	configuration_object.setGlobal_config_object(global_config_object);
	configuration_object.setCorrect_value_config_object(correct_value_config_object);

	configuration_object.setMaster_addr_config_object(master_addr_config_object);
	configuration_object.setMaster_data_config_object(master_data_config_object);
	configuration_object.setMaster_resp_config_object(master_resp_config_object);

	configuration_object.setSlave_addr_config_object(slave_addr_config_object);
	configuration_object.setSlave_data_config_object(slave_data_config_object);
	configuration_object.setSlave_resp_config_object(slave_resp_config_object);

	configuration_object.checkConfigs();

	$display("DONE WRAPPING ");

endfunction

function true_false_enum axi_write_configuration_wrapper::checkIfOptionIsValid(input string option, input string_queue check_queue);

	for(int i = 0; i < check_queue.size(); i++)
		begin
			if(option.icompare(check_queue[i]) == 0)
				begin
					return TRUE;
				end
		end

	return FALSE;
endfunction

function true_false_enum axi_write_configuration_wrapper::findeFullSpeedOption(input config_queue gueue_to_search, output int order_number);
	string option;
	for(int i = 0; i < gueue_to_search.size(); i++)
		begin
			option = gueue_to_search[i].getOption_name();
			if(option.icompare("full_speed") == 0)
				begin
					order_number = i;
					return TRUE;
				end
		end
	order_number = -1;
	return FALSE;

endfunction

`endif