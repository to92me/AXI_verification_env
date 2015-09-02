`ifndef AXI_MASTER_WRITE_SCHEDULER_PACKAGES_SVH
`define AXI_MASTER_WRITE_SCHEDULER_PACKAGES_SVH

//------------------------------------------------------------------------------
//
// CLASS: axi_master_write_arbitration_burst
//
//------------------------------------------------------------------------------
class randomize_data;
		rand int delay;
		rand int delay_data;
		rand int delay_addr;
		rand int delay_awvalid;
		rand int delay_wvalid;
		true_false_enum delay_addr_exists = FALSE;


		constraint delay_cst{
			delay inside {[0 : 50]}; // initial constraint - needst ti be reset for real testing
		}

		constraint deleay_addrdata_csr{
			if(delay_addr_exists == TRUE){
				delay_addr inside {[0:5]};
			}else{
				delay_addr == 0;
				}
			delay_data inside {[0:5]};
		}

		constraint delay_valid_csr{
			delay_awvalid 	inside {[0:5]};
			delay_wvalid 	inside {[0:5]};
		}



endclass: randomize_data



class axi_master_write_scheduler_packages;

	axi_single_frame 		data_queue[$];
	axi_single_frame 		tmp_single_frame;
	axi_single_frame 		one_frame;
	axi_mssg			 	mssg;
	int 					items_in_queue = 0;
	burst_queue_lock_enum	lock_state = QUEUE_LOCKED;
	unique_id_struct 		burst_status;
	first_sent_enum 		first_status = FIRST_NOT_SENT;
	bit [ID_WIDTH-1 : 0] 	ID;
	bit [ADDR_WIDTH -1: 0]	address;
	bit  [7:0]				wlen;
	burst_size_enum			wsize;
	burst_type_enum			wburst;
	axi_frame 				frame_copy;
	int 					slave_error_counter = 0;
	randomize_data 			rand_data;

	semaphore 				sem;

	function new ();
		one_frame = new();
		burst_status = new();
		rand_data = new();
		sem = new(1);
		tmp_single_frame = new();
		frame_copy = new();
	endfunction : new


	extern task getNextSingleFrame(output axi_mssg rps_mssg);
	extern task decrementDelay();
	extern task addSingleFrame(input axi_single_frame frame_for_push);
	extern function int size();
	extern task addBurst(input axi_frame frame);
	extern task empyQueue();
	extern task reincarnate();
	extern function void resetErrorCounter();
	extern function int incrementErrorCounter(); // it returns state = number of error counter
	extern function int getErrorCounter();
	extern function burst_package_info getBurstInfo();

	extern function void calculateStrobe();


endclass : axi_master_write_scheduler_packages



task axi_master_write_scheduler_packages::getNextSingleFrame(output axi_mssg rps_mssg);
	mssg = new();
	// if queue is empty then return QUEUE_EMPTY
	if(data_queue.size == 0)
		begin
			mssg.state = QUEUE_EMPTY;
			mssg.frame = null;
			rps_mssg = mssg;
			return;
		end
	// if there is ready data return that and status READY
	// else return NOT_READY

	one_frame = data_queue.pop_front();
	if (one_frame.delay == 0)
		begin
		mssg.state = READY;
		mssg.frame = one_frame;
		items_in_queue--;
		first_status = FIRST_SENT;
		end
	else
		begin
		mssg.state = NOT_READY;
		mssg.frame = null;
		data_queue.push_front(one_frame);
		end
	rps_mssg = mssg;
endtask


task axi_master_write_scheduler_packages::decrementDelay();
	one_frame = data_queue.pop_front;
	if(one_frame != null)
	begin
		if (one_frame.delay != 0)
			one_frame.delay--;
		data_queue.push_front(one_frame);
	end
endtask

task axi_master_write_scheduler_packages::addSingleFrame(input axi_single_frame frame_for_push);
	// $write(" added data to queu \n");
	items_in_queue++;
    data_queue.push_front(frame_for_push);
endtask

function int axi_master_write_scheduler_packages::size();
    return(data_queue.size);
endfunction

task axi_master_write_scheduler_packages::addBurst(input axi_frame frame);
		int tmp_add = 0;
		$write("\nadded new frame \n");

		for(int i = 0; i<=frame.len; i++)
			begin
				rand_data = new();
				assert(rand_data.randomize);
				tmp_single_frame 			= new();
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
				tmp_single_frame.delay_awvalid 	= rand_data.delay_awvalid;
				tmp_single_frame.delay_wvalid 	= rand_data.delay_wvalid;
				tmp_single_frame.last_one 		= FALSE;
				tmp_single_frame.len			= frame.len+1;
				sem.get(1);
				this.addSingleFrame(tmp_single_frame);
				sem.put(1);
			end


			sem.get(1);
			this.wburst = frame.burst_type;
			this.wlen = frame.len+1;
			this.wsize = frame.size;
			this.frame_copy = frame; // keep the frame copy if recieved error repeat transaction
			this.ID = frame.id;
			data_queue[data_queue.size() -1].last_one = TRUE;
			data_queue[0].first_one = TRUE;
			this.address = frame.addr;

endtask


task axi_master_write_scheduler_packages::empyQueue();

	sem.get(1);
	while(data_queue.size())
		void'(data_queue.pop_front());
	sem.put(1);
endtask

task  axi_master_write_scheduler_packages::reincarnate();
   	$display("recreating burst with ID: %d", this.ID);
	this.empyQueue();
	this.addBurst(this.frame_copy);
endtask

function void axi_master_write_scheduler_packages::resetErrorCounter();
	this.slave_error_counter = 0;
endfunction


function int axi_master_write_scheduler_packages::incrementErrorCounter();
	this.slave_error_counter++;
	return slave_error_counter;
endfunction

function int axi_master_write_scheduler_packages::getErrorCounter();
    return this.slave_error_counter;
endfunction

function burst_package_info axi_master_write_scheduler_packages::getBurstInfo();
	burst_package_info info;
	info = new();
	info.setAddress(this.address);
	info.setBurst(this.wburst);
	info.setID(this.ID);
	info.setWlen(this.wlen);
	info.setWsize(this.wsize);
	return info;
endfunction

function void axi_master_write_scheduler_packages::calculateStrobe();
    axi_address_queue 	strobe_calculator;
	axi_address_calc	strobe_calculator_item;
	mem_access			data_from_single_frame;
	mem_access 			data_to_single_frame;
	bit_byte_union		strobe_data;
	int 				i;
	int 				original_data_line_counter = 0;

	strobe_calculator = new();
	strobe_calculator_item = new();

	strobe_calculator.calc_addr(this.address, this.wsize, this.wlen, this.wburst);
	$display("________________________________________________________________________________________________________");
	$display("BURST INFO: address: %h, size %h, len: %d, burst: %d",this.address, this.wsize, this.wlen, this.wburst );

	foreach(data_queue[i])
		begin
			strobe_calculator_item = strobe_calculator.pop_front();
			data_from_single_frame.data = data_queue[i].data;
			original_data_line_counter = 0;
			strobe_data.one_byte = 'b0;

//			$display("lower lane: %d, upper lane: %d ", strobe_calculator_item.lower_byte_lane,strobe_calculator_item.upper_byte_lane);
//
//			for( int j = strobe_calculator_item.lower_byte_lane; j <= strobe_calculator_item.upper_byte_lane; j++)
//				begin
//					data_to_single_frame.lane[original_data_line_counter] = data_from_single_frame.lane[j];
//					original_data_line_counter++;
//					strobe_data.one_bit[j] = 1'b1;
//				end

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
//			$display("data_from_frame_data: %h: ", data_from_single_frame.data);
//			$display("data_for_frame_data:  %h: ", data_to_single_frame.data);
//			$display("strobe : %b ", strobe_data.one_byte);
			data_queue[i].data = data_to_single_frame.data;
			data_queue[i].strobe = strobe_data.one_byte;
		end
endfunction

`endif
