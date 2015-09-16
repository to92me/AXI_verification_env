`ifndef AXI_MASTER_WRITE_SCHEDULER_PACKAGE2_0_SVH
`define AXI_MASTER_WRITE_SCHEDULER_PACKAGE2_0_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_master_write_scheduler_package2_0 ;
	// local variables
	axi_single_frame		single_frame_queue[$];
	axi_frame				frame_copy;
	randomize_data 			rand_data;
	axi_mssg			 	mssg;
	semaphore 				sem;
	axi_single_frame 		one_frame;
	true_false_enum			all_correct;
	axi_single_frame		tmp_single_frame;
	true_false_enum         sent_last;

	// for scheduler
	burst_queue_lock_enum   lock_state;
	first_sent_enum			first_status;
	int 					response_latenes_counter = 10000;
	int 					error_counter  = 2;


	//configurations
	axi_write_conf							config_obj;
	axi_write_global_conf					global_config_obj;
	axi_write_correct_value_conf			correct_value_config_obj;




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





	function new (string name = "SchedulerPackage",axi_write_conf config_obj);
		//super.new(name);
		this.config_obj = config_obj;

		global_config_obj = config_obj.getGlobal_config_object();
		correct_value_config_obj = config_obj.getCorrect_value_config_object();

		len_randomization 			= new();
		region_randomization		= new();
		id_randomization			= new();
		burst_type_randomization	= new();
		lock_randomization			= new();
		cache_randomization			= new();
		qos_randomization			= new();
		sem 						= new(1);
		one_frame 					= new();
		rand_data 					= new();
	endfunction : new

	// API
	extern task addBurst(axi_frame frame);
	extern task decrementDelay();
	extern task getNextSingleFrame(output axi_mssg rps_mssg);
	extern function int size();
	extern function true_false_enum decrementError_counter();
	extern function void setError_counter(int counter);
	extern task reincarnateBurstData();

	// LOCAL METHODES
	extern function void calculateStrobe();
	extern function void setConfiguration();
	extern function void checkIfAllModesAre1();
	extern function void setValues(axi_frame frame);

	extern function true_false_enum decrementResponseLatenesCounter();

   // Get first_status
   function first_sent_enum getFirst_status();
   	return first_status;
   endfunction

   // Set first_status
   function void setFirst_status(first_sent_enum first_status);
   	this.first_status = first_status;
   endfunction

   // Get lock_state
   function burst_queue_lock_enum getLock_state();
   	return lock_state;
   endfunction

   // Set lock_state
   function void setLock_state(burst_queue_lock_enum lock_state);
   	this.lock_state = lock_state;
   endfunction

   function bit[WID_WIDTH - 1 : 0] getID();
	   return frame_copy.id;
   endfunction

   function axi_frame getFrameCopy();
   		return frame_copy;
   endfunction


endclass : axi_master_write_scheduler_package2_0

task axi_master_write_scheduler_package2_0::addBurst(axi_frame frame);

//	$display("TOME ADDING SCH2_0");

	setConfiguration();

	setValues(frame);
	for(int i = 0; i< frame.len+1; i++)
			begin

				assert(rand_data.randomize);
				tmp_single_frame 				= new();
				tmp_single_frame.data 			= frame.data[i];
				tmp_single_frame.addr 			= frame.addr;
				tmp_single_frame.size 			= frame.size;
				tmp_single_frame.burst_type 	= frame.burst_type;
				tmp_single_frame.lock 			= frame.lock;
				tmp_single_frame.id 			= frame.id;
				tmp_single_frame.cache 			= frame.cache;
				tmp_single_frame.prot			= frame.prot;
				tmp_single_frame.qos 			= frame.qos;
				tmp_single_frame.region 		= frame.region;
				tmp_single_frame.delay 			= rand_data.delay;
				tmp_single_frame.delay_addr 	= rand_data.delay_addr;
				tmp_single_frame.delay_data 	= rand_data.delay_data;
				tmp_single_frame.last_one 		= FALSE;
				tmp_single_frame.len			= frame.len;
				sem.get(1);
				single_frame_queue.push_front(tmp_single_frame);
				sem.put(1);
			end


			sem.get(1);

			this.frame_copy = frame; // keep the frame copy if recieved error repeat transaction

			single_frame_queue[single_frame_queue.size() -1].last_one = TRUE;
			single_frame_queue[0].first_one = TRUE;
			sem.put(1);

			this.calculateStrobe();

//			$display("TOME DONE  SCH2_0");


endtask

task axi_master_write_scheduler_package2_0::decrementDelay();
	one_frame = single_frame_queue.pop_front();
	if(one_frame != null)
	begin
		if (one_frame.delay != 0)
			one_frame.delay--;
		single_frame_queue.push_front(one_frame);
	end
endtask

task axi_master_write_scheduler_package2_0::getNextSingleFrame(output axi_mssg rps_mssg);
	axi_single_frame empty_frame;
	mssg = new();

	// if queue is empty then return QUEUE_EMPTY
	if(single_frame_queue.size() == 0 )
		begin
			if(sent_last == FALSE)
				begin
					`uvm_fatal("Package","NOT LAST")
				end
//			$display("package: id: %h, len: %0d",getID(), this.single_frame_queue.size());
			empty_frame = new();
			empty_frame.id = getID();
			mssg.state = QUEUE_EMPTY;
			mssg.frame = empty_frame;
			rps_mssg = mssg;
			return;
		end
	if(this.lock_state == QUEUE_LOCKED)
		begin
			mssg.state = NOT_READY;
			mssg.frame = null;
			rps_mssg = mssg;
			return;
		end
	// if there is ready data return that and status READY
	// else return NOT_READY

	one_frame = single_frame_queue.pop_front();
	if (one_frame.delay == 0)
		begin
		mssg.state = READY;
		mssg.frame = one_frame;
		first_status = FIRST_SENT;
		end
	else
		begin
		mssg.state = NOT_READY;
		mssg.frame = null;
		single_frame_queue.push_front(one_frame);
		end
	if(one_frame.last_one == TRUE)
		begin
			sent_last = TRUE;
		end
	rps_mssg = mssg;
endtask

function int axi_master_write_scheduler_package2_0::size();
    return(single_frame_queue.size());
endfunction


function void axi_master_write_scheduler_package2_0::calculateStrobe();
    axi_address_queue 	strobe_calculator;
	axi_address_calc	strobe_calculator_item;
	mem_access			data_from_single_frame;
	mem_access 			data_to_single_frame;
	bit_byte_union		strobe_data;
	int 				i;
	int 				original_data_line_counter = 0;

	strobe_calculator = new();
	strobe_calculator_item = new();

	strobe_calculator.calc_addr(frame_copy.addr, frame_copy.size, frame_copy.len, frame_copy.burst_type);
//	$display("________________________________________________________________________________________________________");
//	$display("BURST INFO: address: %h, size %h, len: %d, burst: %d",frame_copy.addr, frame_copy.size, frame_copy.len, frame_copy.burst_type);

	foreach(single_frame_queue[i])
		begin
			strobe_calculator_item = strobe_calculator.pop_front();
			data_from_single_frame.data = single_frame_queue[i].data;
			original_data_line_counter = 0;
			strobe_data.one_byte = 'b0;

			for(int j = 0; j <= (DATA_WIDTH/8); j++)
				begin
					if(j >= strobe_calculator_item.lower_byte_lane && j<= strobe_calculator_item.upper_byte_lane)
						begin
							data_to_single_frame.lane[j] = data_from_single_frame.lane[original_data_line_counter];
							original_data_line_counter++;
							strobe_data.one_bit[j] = 1'b1;
//							$display("j: %dstrobe : %b ",j, strobe_data.one_byte);
						end
					else
						begin
							strobe_data.one_bit[j] = 1'b0;
						end
				end

			single_frame_queue[i].data = data_to_single_frame.data;
			single_frame_queue[i].strobe = strobe_data.one_byte;
		end
endfunction

function void axi_master_write_scheduler_package2_0::setConfiguration();

		rand_data.setDelay_between_packages(global_config_obj.getDelay_between_burst_packages());
		rand_data.setDelay_between_packages_cosntat(global_config_obj.getDelay_between_packages_constant());
		rand_data.setDelay_between_packages_maximum(global_config_obj.getDelay_between_packages_maximum());
		rand_data.setDelay_between_packages_minimum(global_config_obj.getDelay_between_packages_minimum());

		rand_data.setDelay_addr_package(global_config_obj.getDelay_addr_package());
		rand_data.setDelay_data_package(global_config_obj.getDelay_data_package());

		//correct_value_config_obj = config_obj.getCorrect_value_config_object();

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

		checkIfAllModesAre1();
endfunction


function void axi_master_write_scheduler_package2_0::checkIfAllModesAre1();
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


	function void axi_master_write_scheduler_package2_0::setValues(axi_frame frame);
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




	function true_false_enum axi_master_write_scheduler_package2_0::decrementResponseLatenesCounter();
	    response_latenes_counter--;
		if(response_latenes_counter < 1)
			return TRUE;
		else
			return FALSE;
	endfunction


	function true_false_enum axi_master_write_scheduler_package2_0::decrementError_counter();
	    error_counter--;
		if(error_counter < 1)
			return TRUE;
		else
			return FALSE;

	endfunction

	function void axi_master_write_scheduler_package2_0::setError_counter(int counter);
	 	this.error_counter = counter;
	endfunction

	task axi_master_write_scheduler_package2_0::reincarnateBurstData();
	    this.addBurst(this.frame_copy);
	endtask


	`endif

