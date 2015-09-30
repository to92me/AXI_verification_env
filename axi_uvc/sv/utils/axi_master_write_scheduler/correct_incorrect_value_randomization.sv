`ifndef AXI_WRITE_MASTER_CORRECT_INCORRECT_VALUE_RANDOMIZATION_SVH
`define AXI_WRITE_MASTER_CORRECT_INCORRECT_VALUE_RANDOMIZATION_SVH




//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------
class axi_master_write_correct_incorrect_random #(type T = bit[7 : 0]);
	T 					correct_value;
	T 					incorrect_value;
	rand T 					random_value;
	int		 			work_mode;
	int 				correct_dist;
	int 				incorrect_dist;



	constraint correct_incorrect_cs{
		if(work_mode == 1){

			random_value == correct_value;

		}else if(work_mode == 2){

			random_value == incorrect_value;

		}else{
			random_value dist{

			correct_value 	:= correct_dist,
			incorrect_value := incorrect_dist

			};
		}
	}

		// Set correct_dist
		function void setCorrect_dist(int correct_dist);
			this.correct_dist = correct_dist;
		endfunction

		// Set correct_value
		function void setCorrect_value(T correct_value);
			this.correct_value = correct_value;
		endfunction

		// Set incorrect_dist
		function void setIncorrect_dist(int incorrect_dist);
			this.incorrect_dist = incorrect_dist;
		endfunction

		// Set incorrect_value
		function void setIncorrect_value(T incorrect_value);
			this.incorrect_value = incorrect_value;
		endfunction

		// Get random_value
		function T getRandom_value();
			return random_value;
		endfunction

		// Set work_mode
		function void setWork_mode(int work_mode);
			this.work_mode = work_mode;
		endfunction



endclass


//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_master_write_correct_incorrect_value_randomization extends uvm_component;
	axi_write_conf					uvc_config_obj;
	axi_write_correct_value_conf	correct_value_config_obj;
	true_false_enum					all_correct;

	axi_master_write_correct_incorrect_random#(bit [7 : 0]) 				len_randomization;
	axi_master_write_correct_incorrect_random#(bit [3 : 0])     			region_randomization;
	axi_master_write_correct_incorrect_random#(bit [WID_WIDTH-1 : 0])		id_randomization;
	axi_master_write_correct_incorrect_random#(burst_size_enum)				burst_type_randomization;
	axi_master_write_correct_incorrect_random#(lock_enum)					lock_randomization;
	axi_master_write_correct_incorrect_random#(bit [3:0])					cache_randomization;
	axi_master_write_correct_incorrect_random#(bit [3:0])					qos_randomization;

	axi_write_correct_one_value												len_config;
	axi_write_correct_one_value												region_config;
	axi_write_correct_one_value												id_config;
	axi_write_correct_one_value												burst_type_config;
	axi_write_correct_one_value												lock_config;
	axi_write_correct_one_value												cache_config;
	axi_write_correct_one_value												qos_config;



	`uvm_component_utils(axi_master_write_correct_incorrect_value_randomization)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		len_randomization 			= new();
		region_randomization		= new();
		id_randomization			= new();
		burst_type_randomization	= new();
		lock_randomization			= new();
		cache_randomization			= new();
		qos_randomization			= new();
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(axi_write_conf)::get(this, "", "uvc_write_config", uvc_config_obj))
		 `uvm_fatal("NO UVC_CONFIG",{"uvc_write config must be set for ",get_full_name(),".uvc_write_config"})

		 setConfiguration();

	endfunction : build_phase

	extern function void setConfiguration();
	extern function void setValues(ref axi_frame frame);
	extern function void checkIfAllModesAre1();

endclass : axi_master_write_correct_incorrect_value_randomization


	function void axi_master_write_correct_incorrect_value_randomization::setConfiguration();

		correct_value_config_obj = uvc_config_obj.getCorrect_value_config_object();

		len_config			= correct_value_config_obj.getAwlen_conf();
		region_config 		= correct_value_config_obj.getAwregion_conf();
		id_config 			= correct_value_config_obj.getAwid_conf();
		burst_type_config	= correct_value_config_obj.getAwburst_conf();
		lock_config 		= correct_value_config_obj.getAwlock_conf();
		cache_config		= correct_value_config_obj.getAwcache_conf();
		qos_config 			= correct_value_config_obj.getAwqos_conf();

		len_randomization.setWork_mode(len_config.getMode());
		len_randomization.setCorrect_dist(len_config.getDist_correct());
		len_randomization.setIncorrect_dist(len_config.getDist_incorrect());
		len_randomization.setIncorrect_value('b0);

		region_randomization.setWork_mode(region_config.getMode());
		region_randomization.setCorrect_dist(region_config.getDist_correct());
		region_randomization.setIncorrect_dist(region_config.getDist_incorrect());
		region_randomization.setIncorrect_value('b0);

		id_randomization.setWork_mode(id_config.getMode());
		id_randomization.setCorrect_dist(id_config.getDist_correct());
		id_randomization.setIncorrect_dist(id_config.getDist_incorrect());
		id_randomization.setIncorrect_value('b0);


		burst_type_randomization.setWork_mode(burst_type_config.getMode());
		burst_type_randomization.setCorrect_dist(burst_type_config.getDist_correct());
		burst_type_randomization.setIncorrect_dist(burst_type_config.getDist_incorrect());
		burst_type_randomization.setIncorrect_value('b1);


		lock_randomization.setWork_mode(lock_config.getMode());
		lock_randomization.setCorrect_dist(lock_config.getDist_correct());
		lock_randomization.setIncorrect_value(lock_config.getDist_incorrect());
		lock_randomization.setIncorrect_value('b0);

		cache_randomization.setWork_mode(cache_config.getMode());
		cache_randomization.setCorrect_dist(cache_config.getDist_correct());
		cache_randomization.setIncorrect_dist(cache_config.getDist_incorrect());
		cache_randomization.setIncorrect_value('b0);

		qos_randomization.setWork_mode(qos_config.getMode());
		qos_randomization.setCorrect_dist(qos_config.getDist_correct());
		qos_randomization.setIncorrect_dist(qos_config.getDist_incorrect());
		qos_randomization.setIncorrect_value('b0);


	endfunction

	function void axi_master_write_correct_incorrect_value_randomization::checkIfAllModesAre1();


		if( len_config.getMode() == 1 &&
			region_config.getMode() == 1 &&
			id_config.getMode() == 1 &&
			burst_type_config.getMode() == 1 &&
			lock_config.getMode() == 1&&
			cache_config.getMode() == 1 &&
			qos_config.getMode() == 1
			)
			begin
				all_correct = TRUE;
			end
		else
			begin
				all_correct = FALSE;
			end
	endfunction

	function void axi_master_write_correct_incorrect_value_randomization::setValues(ref axi_single_frame frame);
		if(all_correct == TRUE)
			begin
				//this is for optimization because 90% of simulation all data will be correct so for that
				// do not randomize value
				return;
			end
		else
			begin

				len_randomization.setCorrect_value(frame.len);
				assert(len_randomization.randomize());
				frame.len = len_randomization.getRandom_value();

				region_randomization.setCorrect_value(frame.region);
				assert(region_randomization.randomize());
				frame.region = region_randomization.getRandom_value();

				id_randomization.setCorrect_value(frame.id);
				assert(id_randomization.randomize());
				frame.id = id_randomization.getRandom_value();

				burst_type_randomization.setCorrect_value(frame.burst_type);
				assert(burst_type_randomization.randomize());
				frame.burst_type = burst_type_randomization.getRandom_value();

				lock_randomization.setCorrect_value(frame.lock);
				assert(lock_randomization.randomize());
				frame.lock = lock_randomization.getRandom_value();

				cache_randomization.setCorrect_value(frame.cache);
				assert(cache_randomization.randomize());
				frame.cache = cache_randomization.getRandom_value();

				qos_randomization.setCorrect_value(frame.qos);
				assert(qos_randomization.randomize());
				frame.qos = qos_randomization.getRandom_value();

			end
	endfunction

`endif